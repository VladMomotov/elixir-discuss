defmodule DiscussWeb.JobsChannel do
  @moduledoc """
    Websocket channel for handling jobs runs & statuses.
  """

  use DiscussWeb, :channel
  alias DiscussExport.Worker
  alias DiscussWeb.Endpoint

  def join("jobs:export_to_storage", _payload, socket) do
    {:ok, job_id} = start_job(fn -> Worker.perform() end)
    {:ok, %{job_id: job_id}, socket}
  end

  def join("jobs:id:" <> _job_id, _, socket) do
    {:ok, socket}
  end

  def handle_cast({:status_update, job_id, status}, socket) do
    Endpoint.broadcast!("jobs:id:" <> job_id, "status_update", %{status: status})
    {:noreply, socket}
  end

  defp start_job(worker) do
    self_pid = self()
    worker_id = Ecto.UUID.generate()
    on_status_change = fn status ->
      GenServer.cast(self_pid, {:status_update, worker_id, status})
    end

    start_child_res =
      Task.Supervisor.start_child(DiscussWeb.JobsSupervisor, fn ->
        on_status_change.(:working)

        try do
          worker.()
          on_status_change.(:finished)
        rescue
          _error ->
            on_status_change.(:failed)
        end
      end)

    case start_child_res do
      {:ok, _pid} -> {:ok, worker_id}
      error -> error
    end
  end
end
