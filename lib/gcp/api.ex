defmodule GCP.Api do
  @moduledoc """
  Module for Google Cloud Platform REST Api
  """

  @behaviour GCP.ApiBehaviour

  def get_token(scope \\ "https://www.googleapis.com/auth/cloud-platform") do
    {:ok, goth_token} = Goth.Token.for_scope(scope)
    {:ok, %GCP.Token{expires: goth_token.expires, token: goth_token.token}}
  end

  def get_connection(token) do
    %GCP.Connection{tesla_client: GoogleApi.Storage.V1.Connection.new(token)}
  end

  def build_object(params \\ %{}) do
    google_api_object = struct(GoogleApi.Storage.V1.Model.Object, params)
    %GCP.Object{google_api_object: google_api_object}
  end

  def insert_object(connection, bucket, object, data) do
    %GCP.Object{google_api_object: google_api_object} = object
    %GCP.Connection{tesla_client: conn} = connection

    GoogleApi.Storage.V1.Api.Objects.storage_objects_insert_iodata(
      conn,
      bucket,
      "multipart",
      google_api_object,
      data
    )
  end
end
