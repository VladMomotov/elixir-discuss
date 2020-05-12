defmodule GCP.ApiBehaviour do
  @callback get_token(String.t()) :: {:ok, %GCP.Token{}}
  @callback get_token() :: {:ok, %GCP.Token{}}
end
