defmodule DiscussJobs.Job do
  @callback perform(payload :: term) :: {:ok, result :: term} | {:error, reason :: term}

  defmacro __using__(_) do
    quote do
      use GenServer, restart: :transient
      @behaviour unquote(__MODULE__)

      def start_link({job_id, payload, on_status_change}) do
        gen_server_res =
          GenServer.start_link(
            __MODULE__,
            {job_id, on_status_change},
            name: {:via, Registry, {Registry.JobsRegistry, job_id}}
          )

        case gen_server_res do
          {:ok, pid} ->
            GenServer.cast(pid, {:perform, payload})
            {:ok, pid}

          {:error, reason} ->
            {:error, reason}
        end
      end

      def start_job(payload \\ nil, on_status_change \\ nil) do
        job_id = Ecto.UUID.generate()

        start_child_res =
          DiscussJobs.Superviser.start_child(__MODULE__, {job_id, payload, on_status_change})

        case start_child_res do
          {:ok, pid} -> {:ok, job_id}
          error -> error
        end
      end

      @impl true
      def init({job_id, on_status_change}) do
        {:ok, {job_id, nil, on_status_change}}
      end

      @impl true
      def handle_cast({:perform, payload}, {job_id, _, on_status_change}) do
        on_status_change.(job_id, :working)

        result =
          try do
            res = perform(payload)
            on_status_change.(job_id, :finished)
            res
          rescue
            e ->
              on_status_change.(job_id, :failed)
              raise e
          end

        result
      end
    end
  end
end
