defmodule Im.Accounts.Friendship do
  use Ecto.Schema
  import Ecto.Changeset

  alias Im.Accounts.User

  schema "friendships" do
    belongs_to :first_id, User
    belongs_to :second_id, User

    timestamps()
  end

  @doc false
  def changeset(friendship, attrs) do
    friendship
    |> cast(attrs, [:first_id, :second_id])
    |> validate_required([:first_id, :second_id])
  end
end
