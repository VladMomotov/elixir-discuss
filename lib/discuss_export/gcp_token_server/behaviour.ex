defmodule DiscussExport.GCPTokenServer.Behaviour do
  @callback start_link(any()) :: {:error, any()} | {:ok, pid}
  @callback get_token() :: %GCP.Token{}
end
