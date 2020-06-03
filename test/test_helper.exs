Application.load(:discuss)

Application.spec(:discuss, :applications)
|> Enum.map(fn app -> Application.ensure_all_started(app) end)

Supervisor.start_link([Discuss.Repo, DiscussWeb.Endpoint], strategy: :one_for_one, name: Discuss.Supervisor)
Ecto.Adapters.SQL.Sandbox.mode(Discuss.Repo, :manual)

ExUnit.start()
