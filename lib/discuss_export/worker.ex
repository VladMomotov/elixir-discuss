defmodule DiscussExport.Worker do
  alias DiscussExport.GCPTokenServer
  alias Discuss.Posting

  @storage_bucket "posting_export"
  @gcp_api Application.get_env(:discuss_export, :gcp_api)
  @token_server Application.get_env(:discuss_export, :token_server)

  def perform do
    IO.puts("starting export")

    # simulate load
    Process.sleep(3000)

    topics = Posting.list_topics_with_comments()

    for topic <- topics do
      export_topic(topic)
    end

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
    token = @token_server.get_token()
    conn = @gcp_api.get_connection(token.token)

    object = @gcp_api.build_object(%{name: name, contentType: "application/json"})
    @gcp_api.insert_object(conn, @storage_bucket, object, json)
  end
end
