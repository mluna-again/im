defmodule Im.Repo.Migrations.AddOnlineColumnToUsers do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add(:online, :boolean, default: false)
    end
  end
end
