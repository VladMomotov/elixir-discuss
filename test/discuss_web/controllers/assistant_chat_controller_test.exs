defmodule DiscussWeb.AssistantChatControllerTest do
  use DiscussWeb.ConnCase

  require Logger

  describe "index" do
    test "non admin user", %{conn: conn} do
      conn = init_test_session(conn, %{user_id: insert(:user).id})
      conn = get(conn, Routes.assistant_chat_path(conn, :index))

      assert html_response(conn, 403) =~ "You don&#39;t have access to this page"
    end

    test "admin user", %{conn: conn} do
      conn = init_test_session(conn, %{user_id: insert(:user, is_admin: true).id})
      conn = get(conn, Routes.assistant_chat_path(conn, :index))

      assert html_response(conn, 200)
    end
  end

  describe "show" do
    test "chat member", %{conn: conn} do
      user = insert(:user)
      chat = insert(:chat, %{creator: user})

      conn = init_test_session(conn, %{user_id: user.id})
      conn = get(conn, Routes.assistant_chat_path(conn, :show, chat.id))

      assert html_response(conn, 200)
    end

    test "not chat member", %{conn: conn} do
      user = insert(:user)
      chat = insert(:chat)

      conn = init_test_session(conn, %{user_id: user.id})
      conn = get(conn, Routes.assistant_chat_path(conn, :show, chat.id))

      assert html_response(conn, 403)
    end
  end

  describe "show without id" do
    test "if chat already exists", %{conn: conn} do
      chat = insert(:chat)
      user = chat.creator

      conn = init_test_session(conn, %{user_id: user.id})
      conn = get(conn, "/assistant_chat")

      assert html_response(conn, 200)
    end

    test "if chat does not exist", %{conn: conn} do
      user = insert(:user)

      conn = init_test_session(conn, %{user_id: user.id})
      conn = get(conn, "/assistant_chat")

      assert html_response(conn, 200)
      refute Discuss.Repo.preload(user, :assistant_chat).assistant_chat.id == nil
    end
  end
end
