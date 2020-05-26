defmodule DiscussWeb.AssistantChatChannel do
  @moduledoc """
    Websocket channel for assistant chat
  """

  use DiscussWeb, :channel
  alias Discuss.Account
  alias Discuss.AssistantChat

  def join("assistant_chat:" <> chat_id, _auth_msg, socket) do
    with chat <- AssistantChat.get_chat!(chat_id),
         user <- Account.get_user!(socket.assigns.user_id),
         messages <- AssistantChat.list_last_assistant_chat_messages(chat) do
          if AssistantChat.is_chat_member?(chat, user) do
            {:ok, %{chat_id: chat.id, messages: messages}, assign(socket, :chat, chat)}
          end
      end
  end

  def handle_in("assistant_chat:new_message", %{"content" => content}, socket) do
    user = Account.get_user!(socket.assigns.user_id)

    {:ok, message} =
      socket.assigns.chat
      |> Discuss.AssistantChat.create_message(user, %{content: content})

    broadcast!(socket, "assistant_chat:new_message", message)
    {:noreply, socket}
  end
end
