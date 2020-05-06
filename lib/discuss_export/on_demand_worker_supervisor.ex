defmodule DiscussExport.OnDemandWorkerSupervisor do
  alias DiscussExport.Worker

  def start_worker(on_status_change) do
    worker_id = Ecto.UUID.generate()

    start_child_res = Task.Supervisor.start_child(__MODULE__, fn ->
      on_status_change.(worker_id, :working)

      try do
        Worker.perform()
        on_status_change.(worker_id, :finished)
      rescue
        _error ->
          on_status_change.(worker_id, :failed)
      end
    end)

    case start_child_res do
      {:ok, _pid} -> {:ok, worker_id}
      error -> error
    end
  end
end
