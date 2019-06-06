defmodule PizzaApp.Repo do
  use Ecto.Repo,
    otp_app: :pizza_app,
    adapter: Ecto.Adapters.Postgres
end
