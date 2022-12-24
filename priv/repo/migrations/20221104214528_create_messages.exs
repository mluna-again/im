defmodule Im.Repo.Migrations.CreateMessages do
  use Ecto.Migration

  def change do
    create table(:im_messages) do
      add(:content, :string)
      add(:room_id, references(:im_rooms, on_delete: :nothing))
      add(:user_id, references(:im_users, on_delete: :nothing))

      timestamps(type: :utc_datetime)
    end
  end
end
