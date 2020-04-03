defmodule Discuss.Posting.Topic do
  use Ecto.Schema
  import Ecto.Changeset

  schema "topics" do
    field(:title, :string)
    belongs_to(:user, Discuss.Account.User)
    has_many(:comments, Discuss.Posting.Comment)
  end

  @doc false
  def changeset(topic, attrs) do
    topic
    |> cast(attrs, [:title])
    |> validate_required([:title])
  end
end
