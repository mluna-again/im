defmodule Im.Repo.Migrations.CreateRoomsTable do
  use Ecto.Migration

  def change do
    create table(:rooms) do
      add(:first_id, references(:users, on_delete: :nothing))
      add(:second_id, references(:users, on_delete: :nothing))

      timestamps(type: :utc_datetime)
    end
  end
end
