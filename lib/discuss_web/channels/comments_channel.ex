defmodule DiscussWeb.CommentsChannel do
  use DiscussWeb, :channel
  alias Discuss.{Topic, Comment}

  def join("comments:" <> topic_id, _auth_msg, socket) do
    topic_id = String.to_integer topic_id
    topic = Topic
      |> Repo.get(topic_id)
      |> Repo.preload(comments: [:user])

    {:ok, %{comments: topic.comments}, assign(socket, :topic, topic)}
  end

  def handle_in(_event, %{"content" => content}, socket) do
    topic = socket.assigns.topic
    user_id = socket.assigns.user_id

    # todo check how to set multiple relations in latest Phoenix
    changeset = topic
      |> build_assoc(:comments, user_id: user_id)
      |> Comment.changeset(%{content: content})

    case Repo.insert(changeset) do
      {:ok, comment} ->
        broadcast! socket,
                   "comments:#{socket.assigns.topic.id}:new",
                   %{comment: comment}

        {:reply, :ok, socket}
      {:error, _reason} ->
        {:reply, {:error, %{errors: changeset}}, socket}
    end
  end
end
