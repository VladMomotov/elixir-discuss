defmodule DiscussExport.GCPTokenServer.Behaviour do
  @moduledoc """
  Interface for GCPTokenServer
  """

  @callback start_link(any()) :: {:error, any()} | {:ok, pid}
  @callback get_token() :: %GCP.Token{}
end
