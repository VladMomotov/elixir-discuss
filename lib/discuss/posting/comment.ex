defmodule Discuss.Posting.Comment do
  @moduledoc """
    Comment model.
  """

  use Ecto.Schema
  import Ecto.Changeset

  schema "comments" do
    field(:content, :string)
    belongs_to(:user, Discuss.Account.User)
    belongs_to(:topic, Discuss.Posting.Topic)

    timestamps()
  end

  defimpl Jason.Encoder, for: Discuss.Posting.Comment do
    def encode(value, opts) do
      Jason.Encode.map(Map.take(value, [:content]), opts)
    end
  end

  @doc false
  def changeset(comment, attrs) do
    comment
    |> cast(attrs, [:content])
    |> validate_required([:content])
  end
end
