defmodule Im.Accounts do
  @moduledoc """
  The Accounts context.
  """

  import Ecto.Query, warn: false
  alias Im.Repo
  alias Im.Sql

  alias Im.Accounts.{User, FriendRequest, Friendship}
  alias Im.Messages.{Room}

  @doc """
  Returns a list of users that the current user *could* befriend.
  I cannot belive this works. It probably doesn't, but at least looks
  like it does ¯\_(ツ)_/¯.

  Lord forgive me.

  ## Accepted params:
    * search
    * limit - defaults to 5, max 100, min 1

  ## Examples

      iex> list_potential_friends(user, %{})
      [%User{}, ...]
  """
  @spec list_potential_friends(user :: %User{}, params :: term()) :: list(%User{})
  def list_potential_friends(user, params) do
    limit =
      case String.to_integer(params["limit"] || "5") do
        x when x > 100 -> 5
        x when x < 1 -> 5
        x -> x
      end

    search_term = "%#{Sql.sanitize_like_query(params["search"])}%"

    from(u in User,
      left_join: req_sent in "im_friendship_requests",
      on: req_sent.from_id == ^user.id and u.id == req_sent.to_id,
      left_join: req_received in "im_friendship_requests",
      on: req_received.to_id == ^user.id and u.id == req_received.from_id,
      left_join: friendship in Friendship,
      on:
        (friendship.first_id == u.id and friendship.second_id == ^user.id) or
          (friendship.first_id == ^user.id and friendship.second_id == u.id),
      where: u.id != ^user.id,
      limit: ^limit,
      order_by: [desc: u.inserted_at],
      where: ilike(u.username, ^search_term),
      select: %{
        id: u.id,
        username: u.username,
        online: u.online,
        invitation_sent: not is_nil(req_sent.from_id),
        invitation_received: not is_nil(req_received.to_id),
        icon: u.icon,
        friends:
          (friendship.first_id == u.id and friendship.second_id == ^user.id) or
            (friendship.first_id == ^user.id and friendship.second_id == u.id)
      }
    )
    |> Repo.all()
  end

  @doc """
    Sends a friendship request from `sender` to `receiver`.

    ## Example
        iex> send_friend_request(sender, receiver)
        iex> {:ok, %FriendRequest{}}

        iex> send_friend_request(sender, receiver)
        iex> {:ok, %Friendship{}} # when both users sent an invitation to each other

        iex> send_friend_request(sender, non_existing_user)
        iex> {:error, %Ecto.ChangeError{}}
  """
  @spec send_friend_request(sender :: %User{}, receiver :: %User{}) ::
          {:ok, term()} | {:error, term()}
  def send_friend_request(sender, receiver) do
    if friendship = get_friendship(sender, receiver) do
      {:ok, friendship}
    else
      maybe_send_request_or_create_friendship(sender, receiver)
    end
  end

  defp maybe_send_request_or_create_friendship(sender, receiver) do
    # check if receiver sent an invitation first
    inverse_request = Repo.get_by(FriendRequest, from_id: receiver.id, to_id: sender.id)

    if inverse_request do
      Repo.delete(inverse_request)
      # create friendship
      %Friendship{}
      |> Friendship.changeset(%{first_id: sender.id, second_id: receiver.id})
      |> Repo.insert()
    else
      %FriendRequest{}
      |> FriendRequest.changeset(%{from_id: sender.id, to_id: receiver.id})
      |> Repo.insert()
    end
  end

  @doc """
    Checks if `first` and `second` are friends.

    ## Example
        iex> get_friendship(user, another_user)
        iex> %Friendship{}
  """
  @spec get_friendship(first :: %User{}, second :: %User{}) :: %Friendship{} | nil
  def get_friendship(first, second) do
    from(f in Friendship,
      where: f.first_id == ^first.id and f.second_id == ^second.id,
      or_where: f.first_id == ^second.id and f.second_id == ^first.id
    )
    |> Repo.one()
  end

  @doc """
  Returns the list of users.

  ## Examples

      iex> list_users(%{})
      [%User{}, ...]

  """
  def list_users(%{"limit" => limit, "search" => search_term}) when search_term != "" do
    limit = limit || 10

    search_term = "%#{Sql.sanitize_like_query(search_term)}%"

    query =
      from(user in User,
        limit: ^limit,
        order_by: [desc: user.inserted_at],
        where: ilike(user.username, ^search_term)
      )

    Repo.all(query)
  end

  def list_users(_params), do: Repo.all(User)

  @doc """
  Gets a single user.

  Raises `Ecto.NoResultsError` if the User does not exist.

  <rant>
    How is this even possible??? what is even an inner lateral join???
    I don't know what it does, I tried a bunch of stuff before and none worked.
    I saw an example of inner_lateral_join in the Ecto's docs and tried it because
    why not and somehow it worked...

    I'm not responsible for this anymore.

    Computers were a mistake.

    Update:
      So that's why graphQL was created...
      I needed a left lateral join after all.
  </rant>

  ## Examples

      iex> get_user!(123)
      %User{}

      iex> get_user!(456)
      ** (Ecto.NoResultsError)

  """
  def get_user!(id) do
    friends =
      from(f in Friendship,
        where: f.first_id == ^id,
        or_where: f.second_id == ^id,
        join: friend in User,
        on: (friend.id == f.first_id or friend.id == f.second_id) and friend.id != ^id,
        left_join: room in Room,
        on:
          (room.first_id == ^id and room.second_id == friend.id) or
            (room.first_id == friend.id and room.second_id == ^id),
        left_lateral_join:
          last_message in fragment(
            "SELECT * FROM im_messages WHERE room_id = ? ORDER BY inserted_at DESC LIMIT 1",
            room.id
          ),
        order_by:
          fragment(
            "? IS NULL, ? DESC",
            last_message.inserted_at,
            last_message.inserted_at
          ),
        select: %{
          id: friend.id,
          username: friend.username,
          online: friend.online,
          icon: friend.icon,
          friends_since: f.inserted_at,
          last_message: last_message.content,
          last_message_date: last_message.inserted_at,
          pending_messages_count:
            fragment(
              "SELECT COUNT(id) FROM im_messages WHERE room_id = ? AND user_id = ? AND inserted_at > ?",
              room.id,
              friend.id,
              room.last_visited_at
            )
        }
      )
      |> Repo.all()

    Repo.get!(User, id)
    |> Repo.preload(friend_requests: [:from])
    |> Map.put(:friends, friends)
  end

  def get_user_by!(params) do
    user = Repo.get_by!(User, params)
    # double work but i don't feel like duplicating _that_ query...
    get_user!(user.id)
  end

  @doc """
  Returns a list of `user` friends.

  ## Example

      iex> get_user_friends(1)
      iex> [%User{}, ...]
  """
  def get_user_friends(user_id) do
    from(f in Friendship,
      where: f.first_id == ^user_id,
      or_where: f.second_id == ^user_id,
      join: friend in User,
      on: (friend.id == f.first_id or friend.id == f.second_id) and friend.id != ^user_id,
      select: friend
    )
    |> Repo.all()
  end

  @doc """
  Marks a user as online.

  Raises a `Ecto.NoResultsError` if no user exists.

  ## Example

      iex> mark_user_as_online!(1)
      iex> %User{online: true, ...}
  """
  def mark_user_as_online!(user_id) do
    Repo.get!(User, user_id)
    |> User.changeset(%{online: true})
    |> Repo.update!()
  end

  @doc """
  Marks a user as offline.

  Raises a `Ecto.NoResultsError` if no user exists.

  ## Example

      iex> mark_user_as_online!(1)
      iex> %User{online: false, ...}
  """
  def mark_user_as_offline!(user_id) do
    Repo.get!(User, user_id)
    |> User.changeset(%{online: false})
    |> Repo.update!()
  end

  @doc """
  Creates a user.

  ## Examples

      iex> create_user(%{field: value})
      {:ok, %User{}}

      iex> create_user(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_user(attrs \\ %{}) do
    %User{}
    |> User.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a user.

  ## Examples

      iex> update_user(user, %{field: new_value})
      {:ok, %User{}}

      iex> update_user(user, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_user(%User{} = user, attrs) do
    user
    |> User.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Gets a user by username and password.

  ## Examples

      iex> get_user_by_username_and_password(username, password)
      iex> %User{}

      iex> get_user_by_username_and_password(invalid_username, password)
      iex> nil

      iex> get_user_by_username_and_password(username, invalid_password)
      iex> nil
  """
  def get_user_by_username_and_password!(username, password) do
    user = Repo.get_by(User, username: username)

    check_password(user, password)
  end

  defp check_password(nil, _password), do: nil

  defp check_password(user, password) do
    case Bcrypt.check_pass(user, password, hash_key: :password) do
      {:ok, user} -> user
      {:error, _error} -> nil
    end
  end

  @doc """
  Deletes a user.

  ## Examples

      iex> delete_user(user)
      {:ok, %User{}}

      iex> delete_user(user)
      {:error, %Ecto.Changeset{}}

  """
  def delete_user(%User{} = user) do
    Repo.delete(user)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking user changes.

  ## Examples

      iex> change_user(user)
      %Ecto.Changeset{data: %User{}}

  """
  def change_user(%User{} = user, attrs \\ %{}) do
    User.changeset(user, attrs)
  end
end
