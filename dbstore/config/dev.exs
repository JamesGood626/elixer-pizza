use Mix.Config

config :dbstore, Dbstore.Repo,
  adapter: Ecto.Adapters.Posgres,
  database: "pizzadb",
  username: "jamesgood",
  password: "postgres",
  hostname: "localhost",
  pool_size: 10
