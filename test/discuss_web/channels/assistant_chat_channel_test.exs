defmodule DiscussWeb.AssistantChatChannelTest do
  use DiscussWeb.ChannelCase

  alias DiscussWeb.UserSocket
  alias DiscussWeb.AssistantChatChannel
  alias Discuss.AssistantChat
  alias Discuss.AssistantChat.Message

  require Logger

  setup do
    chat = insert(:chat)
    user = chat.creator

    {:ok, _, socket} =
      UserSocket
      |> socket(nil, %{user_id: user.id})
      |> subscribe_and_join(AssistantChatChannel, "assistant_chat:#{chat.id}")

    %{socket: socket, chat: chat, user: user}
  end

  test "assistant_chat:new_message broadcasts new message", %{socket: socket, chat: chat} do
    assert Discuss.Repo.preload(chat, :messages).messages == []

    chat_id = chat.id

    push(socket, "assistant_chat:new_message", %{"content" => "new message"})

    assert_broadcast "assistant_chat:new_message", %Message{
      content: "new message",
      chat_id: ^chat_id
    }
  end

  test "assistant_chat:message_viewed broadcasts updated message", %{
    socket: socket,
    chat: chat,
    user: user
  } do
    message = insert(:message, %{chat: chat, sender: user})
    message_id = message.id

    assert message.was_viewed == false

    push(socket, "assistant_chat:message_viewed:#{message.id}", %{})
    assert_broadcast "assistant_chat:message_viewed", %Message{id: ^message_id, was_viewed: true}
  end

  test "assistant_chat:load_more_messages returns next page", %{
    socket: socket,
    chat: chat,
    user: user
  } do
    first_part =
      insert_list(10, :message, %{chat: chat, sender: user})
      |> Enum.map(fn message -> message.id end)
      |> (fn ids -> Discuss.Repo.all(from m in Message, where: m.id in ^ids) end).()

    second_part =
      insert_list(20, :message, %{chat: chat, sender: user})
      |> Enum.map(fn message -> message.id end)
      |> (fn ids -> Discuss.Repo.all(from m in Message, where: m.id in ^ids) end).()

    ref = push(socket, "assistant_chat:load_more_messages", %{})
    assert_reply(ref, :ok, %{messages: ^second_part, no_more_messages: false})

    ref = push(socket, "assistant_chat:load_more_messages", %{})
    assert_reply(ref, :ok, %{messages: ^first_part, no_more_messages: true})
  end
end
