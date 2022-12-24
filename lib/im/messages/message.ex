defmodule Im.Messages.Message do
  use Ecto.Schema
  import Ecto.Changeset

  alias Im.Messages.Room
  alias Im.Accounts.User

  schema "im_messages" do
    field :content, :string
    belongs_to :room, Room
    belongs_to :user, User

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(message, attrs, from, room) do
    message
    |> cast(attrs, [:content])
    |> validate_required([:content])
    |> put_assoc(:room, room)
    |> put_assoc(:user, from)
  end
end
