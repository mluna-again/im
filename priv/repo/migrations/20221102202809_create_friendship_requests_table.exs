defmodule Im.Repo.Migrations.CreateFriendshipRequestsTable do
  use Ecto.Migration

  def change do
    create table(:friendship_requests) do
      add :from_id, references(:users)
      add :to_id, references(:users)

      timestamps()
    end
  end
end
