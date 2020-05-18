defmodule DiscussWeb.Plugs.SetUser do
  @moduledoc """
    Plug for extract & set user functionality.
  """

  import Plug.Conn
  import Phoenix.Controller

  alias Discuss.Account.User
  alias Discuss.Repo

  def init(_params) do
  end

  def call(conn, _params) do
    user_id = get_session(conn, :user_id)

    if user = user_id && Repo.get(User, user_id) do
      assign(conn, :user, user)
    else
      assign(conn, :user, nil)
    end
  end
end
