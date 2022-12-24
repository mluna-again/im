defmodule Im.Repo.Migrations.CreateUsers do
  use Ecto.Migration

  def change do
    create table(:im_users) do
      add(:username, :string)
      add(:password, :string)

      timestamps(type: :utc_datetime)
    end

    create(unique_index(:im_users, [:username]))
  end
end
