defmodule Im.Accounts.User do
  use Ecto.Schema
  import Ecto.Changeset

  alias Im.Accounts.FriendRequest

  schema "users" do
    field :password, :string
    field :username, :string
    field :icon, :string
    field :invitation_sent, :boolean, virtual: true
    field :invitation_received, :boolean, virtual: true
    field :friends_with_logged, :boolean, virtual: true
    has_many :friend_requests, FriendRequest, foreign_key: :to_id
    # i didn't know how to define this so i populate this on the context...
    # has_many :friends, User

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, [:username, :password])
    |> validate_required([:username, :password])
    |> validate_length(:username, min: 4, max: 15)
    |> validate_length(:password, min: 6, max: 72)
    |> validate_format(:username, ~r/^[[:alnum:]_]+$/)
    |> unique_constraint(:username)
    |> maybe_hash_password()
  end

  defp maybe_hash_password(%{changes: %{password: password}} = changeset) do
    hashed_password = Bcrypt.hash_pwd_salt(password)

    put_change(changeset, :password, hashed_password)
  end

  defp maybe_hash_password(changeset), do: changeset
end
