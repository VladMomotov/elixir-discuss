defmodule DiscussExport.Supervisor do
  use Supervisor
  alias DiscussExport.{GCPTokenServer, WorkerScheduler}

  @spec start_link(any) :: :ignore | {:error, any} | {:ok, pid}
  def start_link(init_arg) do
    Supervisor.start_link(__MODULE__, init_arg, name: __MODULE__)
  end

  @impl true
  def init(_init_arg) do
    children = [
      GCPTokenServer,
      {Task.Supervisor, name: DiscussExport.WorkerSupervisor},
      {WorkerScheduler, Application.get_env(:discuss, DiscussExport)[:worker_frequency]},
      {Task.Supervisor, name: DiscussExport.OnDemandWorkerSupervisor}
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end
end
