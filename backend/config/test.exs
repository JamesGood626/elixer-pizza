use Mix.Config

config :dbstore, Dbstore.Repo,
  adapter: Ecto.Adapters.Posgres,
  database: "pizzadb_test",
  username: "jamesgood",
  password: "postgres",
  hostname: "localhost",
  pool: Ecto.Adapters.SQL.Sandbox

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :backend, BackendWeb.Endpoint,
  http: [port: 4002],
  server: false

# Print only warnings and errors during test
config :logger, level: :warn
