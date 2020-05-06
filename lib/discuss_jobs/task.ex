defmodule DiscussJobs.Task do
  @callback perform(payload :: term) :: {:ok, result :: term} | {:error, reason :: term}

  defmacro __using__(_) do
    quote do
      @behaviour unquote(__MODULE__)

      def start_task(payload \\ nil, on_status_change \\ nil) do
        job_id = Ecto.UUID.generate()

        Task.Supervisor.start_child(supervisor(), fn ->
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
        end)
      end

      defp supervisor do
        @supervisor || DiscussJobs.TaskSupervisor
      end
    end
  end
end
