defmodule DiscussJobs.Job do
  @callback perform(payload :: term) :: {:ok, result :: term} | {:error, reason :: term}

  defmacro __using__(_) do
    quote do
      use GenServer, restart: :transient
      @behaviour unquote(__MODULE__)

      def start_link({job_id, payload}) do
        case GenServer.start_link(__MODULE__, job_id,
               name: {:via, Registry, {Registry.JobsRegistry, job_id}}
             ) do
          {:ok, pid} ->
            GenServer.cast(pid, {:perform, payload})
            {:ok, pid}

          {:error, reason} ->
            {:error, reason}
        end
      end

      def start_job(payload \\ nil) do
        job_id = Ecto.UUID.generate()

        DiscussJobs.Superviser.start_child(__MODULE__, {job_id, payload})
      end

      @impl true
      def init(job_id) do
        {:ok, {job_id, nil}}
      end

      @impl true
      def handle_cast({:perform, payload}, state) do
        perform(payload)
      end
    end
  end
end
