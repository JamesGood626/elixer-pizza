use Mix.Config

config :pizzas, Pizzas.Repo,
  adapter: Ecto.Adapters.Posgres,
  database: "pizzadb",
  username: "jamesgood",
  password: "postgres",
  hostname: "localhost",
  pool: Ecto.Adapters.SQL.Sandbox
