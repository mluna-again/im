defmodule Im.Accounts do
  @moduledoc """
  The Accounts context.
  """

  import Ecto.Query, warn: false
  alias Im.Repo
  alias Im.Sql

  alias Im.Accounts.{User, FriendRequest}

  @doc """
  Returns a list of users that the current user *could* befriend.
  I cannot belive this works. It probably doesn't, but at least looks
  like it does ¯\_(ツ)_/¯.
  *** DON'T TOUCH IT ;( ***

  ## Accepted params:
    * search
    * limit - defaults to 10, max 100, min 1

  ## Examples

      iex> list_potential_friends(user, %{})
      [%User{}, ...]
  """
  @spec list_potential_friends(user_id :: %User{}, params :: term()) :: list(%User{})
  def list_potential_friends(user, params) do
    limit =
      case params["limit"] do
        nil -> 10
        x when x > 100 -> 10
        x when x < 1 -> 10
      end

    search_term = "%#{Sql.sanitize_like_query(params["search"])}%"

    from(u in User,
      left_join: req_sent in "friendship_requests",
      on: req_sent.from_id == ^user.id and u.id == req_sent.to_id,
      left_join: req_received in "friendship_requests",
      on: req_received.to_id == ^user.id and u.id == req_received.from_id,
      where: u.id != ^user.id,
      limit: ^limit,
      order_by: [desc: u.inserted_at],
      where: ilike(u.username, ^search_term),
      select: %{
        id: u.id,
        username: u.username,
        invitation_sent: not is_nil(req_sent.from_id),
        invitation_received: not is_nil(req_received.to_id)
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
    Repo.get_by(FriendRequest, from_id: sender.id)
    |> maybe_send_request_or_create_friendship(sender, receiver)
  end

  defp maybe_send_request_or_create_friendship(_request = nil, sender, receiver) do
    # check if receiver sent an invitation first
    inverse_request = Repo.get_by(FriendRequest, from_id: receiver.id, to_id: sender.id)

    if inverse_request do
      Repo.delete(FriendRequest, inverse_request.id)
      # create friendship
      {:ok, nil}
    else
      %FriendRequest{}
      |> FriendRequest.changeset(%{from_id: sender.id, to_id: receiver.id})
      |> Repo.insert()
    end
  end

  # request already sent
  defp maybe_send_request_or_create_friendship(
         %FriendRequest{from_id: id, to_id: receiver_id} = request,
         %{id: id},
         %{
           id: receiver_id
         }
       ) do
    {:ok, request}
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

  ## Examples

      iex> get_user!(123)
      %User{}

      iex> get_user!(456)
      ** (Ecto.NoResultsError)

  """
  def get_user!(id), do: Repo.get!(User, id)

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
