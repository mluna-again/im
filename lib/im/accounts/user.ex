defmodule Im.Accounts.User do
  use Ecto.Schema
  import Ecto.Changeset

  schema "users" do
    field :password, :string
    field :username, :string

    timestamps()
  end

  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, [:username, :password])
    |> validate_required([:username, :password])
    |> unique_constraint(:username)
    |> maybe_hash_password()
  end

  defp maybe_hash_password(%{changes: %{password: password}} = changeset) do
    hashed_password = Bcrypt.hash_pwd_salt(password)

    put_change(changeset, :password, hashed_password)
  end

  defp maybe_hash_password(changeset), do: changeset
end
