use Mix.Config

config :dbstore, Dbstore.Repo,
  adapter: Ecto.Adapters.Posgres,
  database: "pizzadb",
  username: "jamesgood",
  password: "postgres",
  hostname: "localhost",
  pool: Ecto.Adapters.SQL.Sandbox

config :argon2_elixir,
  t_cost: 1,
  m_cost: 8
