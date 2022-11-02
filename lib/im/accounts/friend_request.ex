defmodule Im.Accounts.FriendRequest do
  use Ecto.Schema
  import Ecto.Changeset

  alias Im.Accounts.User

  schema "friendship_request" do
    belongs_to :from_id, User
    belongs_to :to_id, User

    timestamps()
  end

  @doc false
  def changeset(request, attrs) do
    request
    |> cast(attrs, [:from_id, :to_id])
    |> validate_required([:from_id, :to_id])
  end
end
