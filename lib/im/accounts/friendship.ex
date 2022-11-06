defmodule Im.Accounts.Friendship do
  use Ecto.Schema
  import Ecto.Changeset

  alias Im.Accounts.User

  schema "friendships" do
    belongs_to :first, User
    belongs_to :second, User

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(friendship, attrs) do
    friendship
    |> cast(attrs, [:first_id, :second_id])
    |> validate_required([:first_id, :second_id])
  end
end
