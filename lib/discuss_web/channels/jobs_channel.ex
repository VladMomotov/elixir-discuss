defmodule DiscussWeb.JobsChannel do
  use DiscussWeb, :channel
  alias DiscussExport.OnDemandWorkerSupervisor
  alias DiscussWeb.Endpoint

  def join("jobs:export_to_storage", _payload, socket) do
    self_pid = self()

    callback_fn = fn job_id, status ->
      GenServer.cast(self_pid, {:status_update, job_id, status})
    end

    {:ok, job_id} = OnDemandWorkerSupervisor.start_worker(callback_fn)
    {:ok, %{job_id: job_id}, socket}
  end

  def join("jobs:id:" <> _job_id, _, socket) do
    {:ok, socket}
  end

  def handle_cast({:status_update, job_id, status}, socket) do
    Endpoint.broadcast!("jobs:id:" <> job_id, "status_update", %{status: status})
    {:noreply, socket}
  end
end
