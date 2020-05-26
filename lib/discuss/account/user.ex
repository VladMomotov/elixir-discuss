defmodule Discuss.Account.User do
  @moduledoc """
    User model.
  """

  use Ecto.Schema
  import Ecto.Changeset

  schema "users" do
    field(:email, :string)
    field(:provider, :string)
    field(:token, :string)
    field(:is_admin, :boolean)
    has_many(:topics, Discuss.Posting.Topic)
    has_many(:comments, Discuss.Posting.Comment)
    has_one(:assistant_chat, Discuss.AssistantChat.Chat, foreign_key: :creator_id)

    timestamps()
  end

  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, [:email, :provider, :token])
    |> validate_required([:email, :provider, :token])
  end
end
