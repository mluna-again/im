defmodule Im.Messages do
  @moduledoc """
  The Messages context.
  """

  import Ecto.Query, warn: false
  alias Im.Repo

  alias Im.Messages.{Message, Room}
  alias Im.Accounts.User

  @doc """
  Returns the list of messages.

  ## Examples

      iex> list_messages()
      [%Message{}, ...]

  """
  def list_messages do
    Repo.all(Message)
  end

  @doc """
  Gets a single message.

  Raises `Ecto.NoResultsError` if the Message does not exist.

  ## Examples

      iex> get_message!(123)
      %Message{}

      iex> get_message!(456)
      ** (Ecto.NoResultsError)

  """
  def get_message!(id), do: Repo.get!(Message, id)

  @doc """
  Creates a message.

  ## Examples

      iex> create_message(%{field: value})
      {:ok, %Message{}}

      iex> create_message(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_message(attrs \\ %{}) do
    %Message{}
    |> Message.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a message.

  ## Examples

      iex> update_message(message, %{field: new_value})
      {:ok, %Message{}}

      iex> update_message(message, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_message(%Message{} = message, attrs) do
    message
    |> Message.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a message.

  ## Examples

      iex> delete_message(message)
      {:ok, %Message{}}

      iex> delete_message(message)
      {:error, %Ecto.Changeset{}}

  """
  def delete_message(%Message{} = message) do
    Repo.delete(message)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking message changes.

  ## Examples

      iex> change_message(message)
      %Ecto.Changeset{data: %Message{}}

  """
  def change_message(%Message{} = message, attrs \\ %{}) do
    Message.changeset(message, attrs)
  end

  @doc """
  Gets a room or creates it if it doesn't exist yet.

  ## Examples
      iex> get_room_or_create!(one_user, another_user)
      iex> %Room{}
  """
  @spec get_room_or_create!(first :: %User{}, second :: %User{}) :: %Room{}
  def get_room_or_create!(first, second) do
    room =
      from(room in Room,
        where: room.first_id == ^first.id and room.second_id == ^second.id,
        or_where: room.second_id == ^first.id and room.first_id == ^second.id
      )
      |> Repo.one()

    if room do
      room
    else
      %Room{}
      |> Room.changeset(%{first_id: first.id, second_id: second.id})
      |> Repo.insert!()
    end
  end

  @doc """
  Gets messages between two users.

  Available params:
    * limit -> defaults to 50, min: 1, max: 150

  ## Examples
      iex> list_messages_between_users!(first, second)
      iex> [%Message{}]
  """
  @spec list_messages_between_users!(first :: %User{}, second :: %User{}, params :: map()) ::
          list(%Message{})
  def list_messages_between_users!(first, second, params \\ %{}) do
    room = get_room_or_create!(first, second)

    from(message in Message,
      where: message.room_id == ^room.id,
      limit: ^messages_limit(params),
      order_by: [asc: message.inserted_at]
    )
    |> Repo.all()
  end

  defp messages_limit(%{"limit" => limit}) do
    case String.to_integer(limit) do
      x when x > 150 -> 50
      x when x < 1 -> 50
      x -> x
    end
  end

  defp messages_limit(_), do: 50
end
