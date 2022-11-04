defmodule Im.Repo.Migrations.CreateRoomsTable do
  use Ecto.Migration

  def change do
    create table(:rooms) do
      add(:first, references(:users, on_delete: :nothing))
      add(:second, references(:users, on_delete: :nothing))

      timestamps()
    end
  end
end
