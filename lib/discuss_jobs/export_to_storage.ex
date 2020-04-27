defmodule DiscussJobs.ExportToStorage do
  use DiscussJobs.Job
  alias Discuss.Posting

  @storage_bucket "posting_export"

  @impl true
  def perform(_) do
    topics = Posting.list_topics_with_comments()

    for topic <- topics do
      export_topic(topic)
    end

    {:stop, :normal, :ok}
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
    {:ok, token} = Goth.Token.for_scope("https://www.googleapis.com/auth/cloud-platform")
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
