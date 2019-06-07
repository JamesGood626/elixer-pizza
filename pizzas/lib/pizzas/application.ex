defmodule Pizzas.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    IO.puts("pizzas Application start/2 called")
    # List all child processes to be supervised
    children = [
      # Starts a worker by calling: Pizzas.Worker.start_link(arg)
      # {Pizzas.Worker, arg}
      Pizzas.Repo
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Pizzas.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
