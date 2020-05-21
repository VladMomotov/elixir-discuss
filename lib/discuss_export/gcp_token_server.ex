defmodule DiscussExport.GCPTokenServer do
  @moduledoc """
    GenServer that handles Google Cloud Platform tokens.
  """

  use GenServer
  @behaviour DiscussExport.GCPTokenServer.Behaviour

  @gcp_api Application.get_env(:discuss, :discuss_export)[:gcp_api]

  # Client

  @impl true
  def start_link(init_arg) do
    GenServer.start_link(__MODULE__, init_arg, name: __MODULE__)
  end

  @impl true
  def get_token do
    # retrieving new token can take some time
    GenServer.call(__MODULE__, :get, 20_000)
  end

  # Server

  @impl true
  def init(_) do
    {:ok, nil}
  end

  @impl true
  def handle_info(:update, _) do
    IO.puts("token expired")
    {:noreply, nil}
  end

  @impl true
  def handle_call(:get, _from, state) do
    token =
      case state do
        nil -> retrieve_token()
        token -> token
      end

    {:reply, token, token}
  end

  defp retrieve_token do
    IO.puts("retrieving token")
    {:ok, token} = @gcp_api.get_token()
    schedule_update(token.expires)

    token
  end

  defp schedule_update(expiration_datetime) do
    unix_now = DateTime.utc_now() |> DateTime.to_unix()
    delay = (expiration_datetime - unix_now) * 1000

    IO.puts("token will be updated in #{delay / 1000} seconds")

    Process.send_after(self(), :update, delay)
  end
end
