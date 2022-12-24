defmodule Im.Repo.Migrations.CreateFriendshipRequestsTable do
  use Ecto.Migration

  def change do
    create table(:im_friendship_requests) do
      add(:from_id, references(:im_users))
      add(:to_id, references(:im_users))

      timestamps(type: :utc_datetime)
    end
  end
end
