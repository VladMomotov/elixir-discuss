defmodule DiscussWeb.CommentsChannel do
  use DiscussWeb, :channel
  alias Discuss.Posting
  alias DiscussWeb.CommentView

  def join("comments:" <> topic_id, _auth_msg, socket) do
    topic_id = String.to_integer(topic_id)
    topic = Posting.get_topic!(topic_id)
    view = CommentView.render("index.json", data: topic.comments)

    {:ok, %{comments: view}, assign(socket, :topic, topic)}
  end

  def handle_in(_event, %{"content" => content}, socket) do
    topic = socket.assigns.topic
    user_id = socket.assigns.user_id

    # todo check how to set multiple relations in latest Phoenix
    changeset =
      topic
      |> build_assoc(:comments, user_id: user_id)
      |> Posting.Comment.changeset(%{content: content})

    case Repo.insert(changeset) do
      {:ok, comment} ->
        comment = comment |> Repo.preload(:user)
        view = CommentView.render("show.json", data: comment)

        broadcast!(
          socket,
          "comments:#{socket.assigns.topic.id}:new",
          %{comment: view}
        )

        {:reply, :ok, socket}

      {:error, _reason} ->
        {:reply, {:error, %{errors: changeset}}, socket}
    end
  end
end
