defmodule Discuss.Posting.Topic do
  use Ecto.Schema
  import Ecto.Changeset

  schema "topics" do
    field(:title, :string)
    belongs_to(:user, Discuss.Account.User)
    has_many(:comments, Discuss.Posting.Comment)
  end

  defimpl Jason.Encoder, for: Discuss.Posting.Topic do
    def encode(value, opts) do
      Jason.Encode.map(Map.take(value, [:title, :comments]), opts)
    end
  end

  @doc false
  def changeset(topic, attrs) do
    topic
    |> cast(attrs, [:title])
    |> validate_required([:title])
  end
end
