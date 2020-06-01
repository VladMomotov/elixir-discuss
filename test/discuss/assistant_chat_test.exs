defmodule Discuss.AssistantChatTest do
  use Discuss.DataCase

  alias Discuss.AssistantChat

  def user_fixture(attrs \\ %{}) do
    {:ok, user} =
      attrs
      |> Enum.into(%{email: "some email", provider: "some provider", token: "some token"})
      |> Discuss.Account.create_user()

    user
  end

  def chat_fixture(attrs \\ %{}) do
    creator = user_fixture()
    {:ok, chat} = AssistantChat.create_chat(creator, attrs)

    chat
  end

  describe "assistant_chat_messages" do
    alias Discuss.AssistantChat.Message

    @valid_attrs %{content: "some content", receiver_id: 42, was_viewed: true}
    @update_attrs %{
      content: "some updated content",
      receiver_id: 43,
      sender_id: 43,
      was_viewed: false
    }
    @invalid_attrs %{content: nil, receiver_id: nil, was_viewed: nil}

    def message_fixture(attrs \\ %{}) do
      chat = chat_fixture()
      creator = user_fixture()

      attrs = attrs |> Enum.into(@valid_attrs)
      {:ok, message} = AssistantChat.create_message(chat, creator, attrs)

      message
    end

    test "list_assistant_chat_messages/0 returns all assistant_chat_messages" do
      message = message_fixture()


      assert AssistantChat.list_assistant_chat_messages() |> Discuss.Repo.preload(:sender) == [message]
    end

    test "get_message!/1 returns the message with given id" do
      message = message_fixture()
      assert AssistantChat.get_message!(message.id) |> Discuss.Repo.preload(:sender) == message
    end

    test "create_message/1 with valid data creates a message" do
      chat = chat_fixture()
      sender = user_fixture()

      assert {:ok, %Message{} = message} = AssistantChat.create_message(chat, sender, @valid_attrs)
      assert message.content == "some content"
      assert message.receiver_id == 42
      assert message.sender_id == sender.id
      assert message.was_viewed == true
    end

    test "update_message/2 with valid data updates the message" do
      message = message_fixture()
      assert {:ok, %Message{} = message} = AssistantChat.update_message(message, @update_attrs)
      assert message.content == "some updated content"
      assert message.receiver_id == 43
      assert message.was_viewed == false
    end

    test "update_message/2 with invalid data returns error changeset" do
      message = message_fixture()
      assert {:error, %Ecto.Changeset{}} = AssistantChat.update_message(message, @invalid_attrs)
      assert message == AssistantChat.get_message!(message.id) |> Discuss.Repo.preload(:sender)
    end

    test "delete_message/1 deletes the message" do
      message = message_fixture()
      assert {:ok, %Message{}} = AssistantChat.delete_message(message)
      assert_raise Ecto.NoResultsError, fn -> AssistantChat.get_message!(message.id) end
    end

    test "change_message/1 returns a message changeset" do
      message = message_fixture()
      assert %Ecto.Changeset{} = AssistantChat.change_message(message)
    end
  end

  describe "chats" do
    alias Discuss.AssistantChat.Chat

    @valid_attrs %{}

    test "list_chats/0 returns all chats" do
      chat = chat_fixture() |> Repo.preload(:creator)

      assert AssistantChat.list_chats() == [chat]
    end

    test "get_chat!/1 returns the chat with given id" do
      chat = chat_fixture()
      assert AssistantChat.get_chat!(chat.id) == chat
    end

    test "create_chat/1 with valid data creates a chat" do
      creator = user_fixture()
      assert {:ok, %Chat{} = chat} = AssistantChat.create_chat(creator, @valid_attrs)
      assert chat.creator_id == creator.id
    end

    test "delete_chat/1 deletes the chat" do
      chat = chat_fixture()
      assert {:ok, %Chat{}} = AssistantChat.delete_chat(chat)
      assert_raise Ecto.NoResultsError, fn -> AssistantChat.get_chat!(chat.id) end
    end

    test "change_chat/1 returns a chat changeset" do
      chat = chat_fixture()
      assert %Ecto.Changeset{} = AssistantChat.change_chat(chat)
    end
  end
end
