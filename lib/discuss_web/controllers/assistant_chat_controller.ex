defmodule DiscussWeb.AssistantChatController do
  use DiscussWeb, :controller

  alias Discuss.Account
  alias Discuss.AssistantChat

  plug Discuss.Plugs.RequireAuth

  def index(conn, _params) do
    # only admins can see all chats
    if conn.assigns.user && conn.assigns.user.is_admin do
      chats = AssistantChat.list_chats()
      render(conn, "index.html", chats: chats)
    else
      conn
      |> put_status(403)
      |> put_view(DiscussWeb.ErrorView)
      |> render(:"403")
    end
  end

  def show(conn, %{"id" => chat_id}) do
    chat = AssistantChat.get_chat!(chat_id)

    if AssistantChat.is_chat_member?(chat, conn.assigns.user) do
      render(conn, "show.html", chat: chat)
    else
      conn
      |> put_status(403)
      |> put_view(DiscussWeb.ErrorView)
      |> render(:"403")
    end
  end

  # when there is no id in route - treat as default user's chat
  def show(conn, %{}) do
    user = conn.assigns.user
    chat = user.assistant_chat

    chat =
      if chat == nil do
        {:ok, chat} = AssistantChat.create_chat(user)
        chat
      else
        chat
      end

    render(conn, "show.html", chat: chat)
  end
end
