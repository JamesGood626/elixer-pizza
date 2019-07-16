use Mix.Config

config :dbstore, Dbstore.Repo,
  adapter: Ecto.Adapters.Posgres,
  database: "pizzadb_test",
  username: "jamesgood",
  password: "postgres",
  hostname: "localhost",
  pool: Ecto.Adapters.SQL.Sandbox
