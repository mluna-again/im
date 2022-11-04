defmodule Im.Repo.Migrations.CreateMessages do
  use Ecto.Migration

  def change do
    create table(:messages) do
      add :content, :string
      add :room, references(:rooms, on_delete: :nothing)

      timestamps()
    end

    create index(:messages, [:room])
  end
end
