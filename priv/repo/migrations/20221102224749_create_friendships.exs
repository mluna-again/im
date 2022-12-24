defmodule Im.Repo.Migrations.CreateFriendships do
  use Ecto.Migration

  def change do
    create table(:im_friendships) do
      add(:first_id, references(:im_users))
      add(:second_id, references(:im_users))

      timestamps(type: :utc_datetime)
    end
  end
end
