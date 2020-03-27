defmodule Discuss.CommentsChannel do
  use Discuss.Web, :channel

  def join(topic, _auth_msg, socket) do
    IO.puts("+++++++++")
    IO.puts(topic)

    {:ok, %{hey: "there"}, socket}
  end

  def handle_in(_event, _msg, _arg2) do
  end
end