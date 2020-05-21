defmodule DiscussExport.Supervisor do
  @moduledoc """
    Main supervisor of DiscussExport.
  """

  use Supervisor
  alias DiscussExport.{GCPTokenServer, WorkerScheduler}

  @spec start_link(any) :: :ignore | {:error, any} | {:ok, pid}
  def start_link(init_arg) do
    Supervisor.start_link(__MODULE__, init_arg, name: __MODULE__)
  end

  @impl true
  def init(_init_arg) do
    # Scheduler depends on WorkerSupervisor
    # each worker under WorkerSupervisor depends on GCPTokenServer

    children = [
      GCPTokenServer,
      {Task.Supervisor, name: DiscussExport.WorkerSupervisor},
      {WorkerScheduler, Application.get_env(:discuss, DiscussExport)[:worker_frequency]}
    ]

    Supervisor.init(children, strategy: :rest_for_one)
  end
end
