defmodule Im.Repo.Migrations.CreateFriendships do
  use Ecto.Migration

  def change do
    create table(:friendships) do
      add(:first_id, references(:users))
      add(:second_id, references(:users))

      timestamps(type: :utc_datetime)
    end
  end
end
