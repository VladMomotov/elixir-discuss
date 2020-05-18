defmodule DiscussExport.Worker do
  @moduledoc """
    Export topic & comments worker.
  """

  alias Discuss.Posting
  alias DiscussExport.GCPTokenServer

  @storage_bucket "posting_export"

  def perform do
    IO.puts("starting export")

    # simulate load
    Process.sleep(3000)

    Posting.list_topics_with_comments()
    |> Enum.each(&export_topic/1)

    IO.puts("finishing export")
  end

  defp export_topic(topic) do
    # GoogleApi uses Poison underneath. I do not want to support Poison and implement protocol for poison,
    # so using Jason encoding -> decoding to leave only necessary fields in model.
    # when GoogleApi switchs to Jason we can easily remove Jason.encode & Jason.decode

    topic
    |> Jason.encode()
    |> elem(1)
    |> Jason.decode()
    |> elem(1)
    |> export_json("#{topic.id}.json")
  end

  defp export_json(json, name) do
    token = GCPTokenServer.get_token()
    conn = GoogleApi.Storage.V1.Connection.new(token.token)

    object = %GoogleApi.Storage.V1.Model.Object{name: name, contentType: "application/json"}

    GoogleApi.Storage.V1.Api.Objects.storage_objects_insert_iodata(
      conn,
      @storage_bucket,
      "multipart",
      object,
      json
    )
  end
end
