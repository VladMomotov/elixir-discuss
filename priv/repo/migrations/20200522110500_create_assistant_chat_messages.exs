defmodule Discuss.Repo.Migrations.CreateAssistantChatMessages do
  use Ecto.Migration

  def change do
    create table(:assistant_chat_messages) do
      add :sender_id, :integer
      add :receiver_id, :integer
      add :content, :text
      add :was_viewed, :boolean, default: false, null: false

      timestamps()
    end

  end
end
