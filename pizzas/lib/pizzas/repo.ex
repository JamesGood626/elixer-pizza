defmodule Pizzas.Repo do
  use Ecto.Repo,
    otp_app: :pizzas,
    adapter: Ecto.Adapters.Postgres
end
