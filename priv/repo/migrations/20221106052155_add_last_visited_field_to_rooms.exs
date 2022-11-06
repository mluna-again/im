defmodule Im.Repo.Migrations.AddLastVisitedFieldToRooms do
  use Ecto.Migration

  def change do
    alter table(:rooms) do
      add(:last_visited_at, :utc_datetime)
    end
  end
end
