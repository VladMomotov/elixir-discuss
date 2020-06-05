defmodule Discuss.Repo.Migrations.CreateChats do
  use Ecto.Migration

  def change do
    create table(:assistant_chats) do
      add(:creator_id, :integer)

      timestamps()
    end
  end
end
