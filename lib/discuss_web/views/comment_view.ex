defmodule DiscussWeb.CommentView do
  use DiscussWeb, :view
  alias DiscussWeb.UserView

  @attributes ~w(content user)a

  def render("index.json", %{data: comments}) do
    for comment <- comments do
      render("show.json", data: comment)
    end
  end

  def render("show.json", %{data: comment}) do
    comment
    |> Map.take(@attributes)
    |> Map.put(:user, UserView.render("show.json", data: comment.user))
  end
end
