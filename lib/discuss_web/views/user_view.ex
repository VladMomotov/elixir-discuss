defmodule DiscussWeb.UserView do
  use DiscussWeb, :view
  @attributes ~w(email)a

  def render("show.json", %{data: nil}), do: nil

  def render("show.json", %{data: user}) do
    user
    |> Map.take(@attributes)
  end
end
