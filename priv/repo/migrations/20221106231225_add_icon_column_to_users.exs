defmodule Im.Repo.Migrations.AddIconColumnToUsers do
  use Ecto.Migration

  def change do
    alter table(:im_users) do
      add(:icon, :string, default: "default")
    end
  end
end
