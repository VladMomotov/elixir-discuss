defmodule Discuss.AssistantChat.Chat do
  use Ecto.Schema
  import Ecto.Changeset

  schema "assistant_chats" do
    belongs_to(:creator, Discuss.Account.User)
    has_many(:messages, Discuss.AssistantChat.Message)

    timestamps()
  end

  defimpl Jason.Encoder, for: Discuss.AssistantChat.Chat do
    def encode(value, opts) do
      Jason.Encode.map(Map.take(value, [:id]), opts)
    end
  end

  @doc false
  def changeset(chat, attrs) do
    chat
    |> cast(attrs, [:creator_id])
    |> validate_required([:creator_id])
  end
end
