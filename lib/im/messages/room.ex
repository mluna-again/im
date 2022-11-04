defmodule Im.Messages.Room do
  use Ecto.Schema
  import Ecto.Changeset

  alias Im.Accounts.User

  schema "rooms" do
    belongs_to :first, User
    belongs_to :second, User

    timestamps()
  end

  @doc false
  def changeset(room, attrs) do
    room
    |> cast(attrs, [:first_id, :second_id])
    |> validate_required([:first_id, :second_id])
  end
end
