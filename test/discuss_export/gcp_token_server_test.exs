defmodule DiscussExport.GCPTokenServerTest do
  use ExUnit.Case
  import Mox
  alias DiscussExport.GCPTokenServer

  setup :verify_on_exit!

  describe "get_token" do
    test "retrieve token" do
      GCP.ApiMock
      |> expect(:get_token, fn -> {:ok, %GCP.Token{expires: one_hour_later()}} end)

      {:ok, _pid} = GCPTokenServer.start_link(nil)
      allow(GCP.ApiMock, self(), GCPTokenServer)

      assert %GCP.Token{} = GCPTokenServer.get_token()
    end

    test "get existing token" do
      GCP.ApiMock
      |> expect(:get_token, fn -> {:ok, %GCP.Token{expires: one_hour_later()}} end)

      {:ok, _pid} = GCPTokenServer.start_link(nil)
      allow(GCP.ApiMock, self(), GCPTokenServer)


      first_token = GCPTokenServer.get_token()
      second_token = GCPTokenServer.get_token()

      assert first_token === second_token
    end

    test "token expiration" do
      GCP.ApiMock
      |> expect(:get_token, 2, fn -> {:ok, %GCP.Token{expires: one_second_later()}} end)

      {:ok, _pid} = GCPTokenServer.start_link(nil)
      allow(GCP.ApiMock, self(), GCPTokenServer)

      GCPTokenServer.get_token()
      Process.sleep(1000)

      GCPTokenServer.get_token()
    end
  end


  defp one_hour_later do
    DateTime.utc_now()
    |> DateTime.add(60*60, :seconds)
    |> DateTime.to_unix()
  end

  defp one_second_later do
    DateTime.utc_now()
    |> DateTime.add(1, :seconds)
    |> DateTime.to_unix()
  end
end
