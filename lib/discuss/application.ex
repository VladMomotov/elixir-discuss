defmodule Discuss.Application do
  use Application

  # See http://elixir-lang.org/docs/stable/elixir/Application.html
  # for more information on OTP Applications
  def start(_type, _args) do
    # Define workers and child supervisors to be supervised
    children = [
      # Start the Ecto repository
      Discuss.Repo,
      # Start the endpoint when the application starts
      DiscussWeb.Endpoint,
      {Task.Supervisor, name: DiscussWeb.JobsSupervisor},
      DiscussExport.Supervisor
    ]

    # See http://elixir-lang.org/docs/stable/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Discuss.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    DiscussWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
