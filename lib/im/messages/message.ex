defmodule Im.Messages.Message do
  use Ecto.Schema
  import Ecto.Changeset

  alias Im.Messages.Room
  alias Im.Accounts.User

  schema "messages" do
    field :content, :string
    belongs_to :room, Room
    belongs_to :user, User

    timestamps()
  end

  @doc false
  def changeset(message, attrs) do
    message
    |> cast(attrs, [:content])
    |> validate_required([:content])
  end
end
