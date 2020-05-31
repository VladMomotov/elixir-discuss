defmodule Discuss.Repo.Migrations.AddChatIdInMessage do
  use Ecto.Migration

  def change do
    alter table("assistant_chat_messages") do
      add(:chat_id, references("assistant_chats"))
    end
  end
end
