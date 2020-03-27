defmodule Discuss.CommentsChannel do
  use Discuss.Web, :channel

  def join(_topic, _auth_msg, socket) do
    {:ok, %{hey: "there"}, socket}
  end

  def handle_in(event, msg, socket) do
    {:reply, :ok, socket}
  end
end