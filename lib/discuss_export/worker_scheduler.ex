defmodule DiscussExport.WorkerScheduler do
  use GenServer
  alias DiscussExport.{Worker}

  def start_link(init_arg) do
    GenServer.start_link(__MODULE__, init_arg, name: __MODULE__)
  end

  @impl true
  def init(frequency) do
    send(self(), :start)

    {:ok, frequency}
  end

  @impl true
  def handle_info(:start, frequency) do
    Task.Supervisor.start_child(DiscussExport.WorkerSupervisor, Worker, :perform, [])
    schedule_worker(frequency)

    {:noreply, frequency}
  end

  defp schedule_worker(delay) do
    Process.send_after(self(), :start, delay)
  end
end
