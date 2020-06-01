defmodule Discuss.AssistantChat.Message do
  use Ecto.Schema
  import Ecto.Changeset

  schema "assistant_chat_messages" do
    field(:content, :string)
    field(:receiver_id, :integer)
    field(:was_viewed, :boolean, default: false)
    belongs_to(:sender, Discuss.Account.User)
    belongs_to(:chat, Discuss.AssistantChat.Chat)

    timestamps()
  end

  defimpl Jason.Encoder, for: Discuss.AssistantChat.Message do
    def encode(value, opts) do
      Jason.Encode.map(Map.take(value, [:id, :content, :sender_id, :was_viewed, :chat_id]), opts)
    end
  end

  @doc false
  def changeset(message, attrs) do
    message
    |> cast(attrs, [:receiver_id, :content, :was_viewed])
    |> cast_assoc(:sender, required: true)
    |> validate_required([:content, :was_viewed])
  end
end
