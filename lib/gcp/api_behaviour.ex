defmodule GCP.ApiBehaviour do
  @callback get_token(String.t()) :: {:ok, %GCP.Token{}}
  @callback get_token() :: {:ok, %GCP.Token{}}
  @callback get_connection(String.t()) :: %GCP.Connection{}
  @callback build_object(map()) :: %GCP.Object{}
  @callback insert_object(%GCP.Connection{}, String.t(), %GCP.Object{}, iodata) :: none()
end
