defmodule DiscussWeb.AssistantChatChannel do
  @moduledoc """
    Websocket channel for assistant chat
  """

  use DiscussWeb, :channel
  alias Discuss.Account
  alias Discuss.AssistantChat

  def join("assistant_chat:" <> chat_id, _auth_msg, socket) do
    with chat <- AssistantChat.get_chat!(chat_id),
         user <- Account.get_user!(socket.assigns.user_id) do
          if AssistantChat.is_chat_member?(chat, user) do
            messages_paginator = first_page(chat)

            messages = messages_paginator.entries |> Enum.reverse()

            no_more_messages = messages_paginator.metadata.after == nil

            socket = socket
                      |> assign(:chat, chat)
                      |> assign(:messages_paginator, messages_paginator)

            {:ok, %{chat_id: chat.id, messages: messages, no_more_messages: no_more_messages}, socket}
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

  def handle_in("assistant_chat:message_viewed:" <> message_id, _params, socket) do
    with chat <- socket.assigns.chat,
         message <- AssistantChat.get_message!(message_id) do
          if message.chat_id === chat.id do
            AssistantChat.update_message(message, %{was_viewed: true})
            broadcast!(socket, "assistant_chat:message_viewed", message)
            {:noreply, socket}
          end
    end
  end

  def handle_in("assistant_chat:load_more_messages", _params, socket) do
    messages_paginator = next_page(socket.assigns.messages_paginator, socket.assigns.chat)
    messages = messages_paginator.entries |> Enum.reverse()

    no_more_messages = messages_paginator.metadata.after == nil

    socket = assign(socket, :messages_paginator, messages_paginator)
    {:reply, {:ok, %{messages: messages, no_more_messages: no_more_messages}}, socket}
  end

  defp take_out_messages(socket, paginator) do
    messages = paginator.entries |> Enum.reverse()

    if paginator.metadata.after == nil do
      push(socket, "assistant_chat:no_more_messages", %{})
    end

    messages
  end

  defp first_page(chat) do
    AssistantChat.list_assistant_chat_messages_query(chat)
    |> Discuss.Repo.paginate(cursor_fields: [{:inserted_at, :desc}, {:id, :desc}], limit: 2, include_total_count: true)
  end

  defp next_page(paginator, chat) do
    cursor_after = paginator.metadata.after

    AssistantChat.list_assistant_chat_messages_query(chat)
    |> Discuss.Repo.paginate(cursor_fields: [{:inserted_at, :desc}, {:id, :desc}], limit: 2, after: cursor_after, include_total_count: true)
  end

end
