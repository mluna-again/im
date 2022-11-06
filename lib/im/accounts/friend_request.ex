defmodule Im.Accounts.FriendRequest do
  use Ecto.Schema
  import Ecto.Changeset

  alias Im.Accounts.User

  schema "friendship_requests" do
    belongs_to :from, User
    belongs_to :to, User

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(request, attrs) do
    request
    |> cast(attrs, [:from_id, :to_id])
    |> validate_required([:from_id, :to_id])
  end
end
