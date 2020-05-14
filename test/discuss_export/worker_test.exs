defmodule DiscussExport.WorkerTest do
  use ExUnit.Case, async: true
  alias DiscussExport.Worker

  import Mox
  setup :verify_on_exit!

  setup do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(Discuss.Repo)
    Discuss.Posting.create_topic(%{title: "test topic"})

    test_token = %GCP.Token{token: :test_token}
    test_connection = %GCP.Connection{}
    test_object = %GCP.Object{}

    test_json = %{"title" => "test topic", "comments" => []}

    %{token: test_token, connection: test_connection, object: test_object, json: test_json}
  end

  test "perform", %{token: token, connection: connection, object: object, json: json} do
    GCPTokenServerMock
    |> expect(:get_token, fn -> token end)
    GCP.ApiMock
    |> expect(:get_connection, fn :test_token -> connection end)
    |> expect(:build_object, fn _map -> object end)
    |> expect(:insert_object, fn ^connection, _, ^object, ^json  -> nil end)

    Worker.perform()
  end
end
