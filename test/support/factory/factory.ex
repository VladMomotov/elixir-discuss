defmodule Discuss.Factory do
  use ExMachina.Ecto, repo: Discuss.Repo

  def user_factory do
    %Discuss.Account.User{
      email: "some email",
      provider: "some provider",
      token: "some token"
    }
  end

  def chat_factory(attrs \\ %{}) do
    creator = Map.get(attrs, :creator, build(:user))

    %Discuss.AssistantChat.Chat{
      creator: creator
    }
  end

  def message_factory(attrs \\ %{}) do
    chat = Map.get(attrs, :chat, build(:chat))
    sender = Map.get(attrs, :sender, build(:user))

    %Discuss.AssistantChat.Message{
      content: "message content",
      chat: chat,
      sender: sender
    }
  end
end
