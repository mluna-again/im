defmodule Im.Messages.Room do
  use Ecto.Schema
  import Ecto.Changeset

  alias Im.Accounts.User

  schema "rooms" do
    belongs_to :first, User
    belongs_to :second, User
    field :last_visited_at, :utc_datetime

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(room, attrs) do
    room
    |> cast(attrs, [:first_id, :second_id])
    |> validate_required([:first_id, :second_id])
  end

  def visited_changeset(room) do
    room
    |> change()
    |> put_change(:last_visited_at, DateTime.truncate(DateTime.utc_now(), :second))
  end
end
