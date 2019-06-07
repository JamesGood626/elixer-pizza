defmodule Accounts.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    IO.puts("accounts Application start/2 called")
    IO.inspect(System.get_env("MIX_ENV"))
    # List all child processes to be supervised
    children = [
      # Starts a worker by calling: Accounts.Worker.start_link(arg)
      # {Accounts.Worker, arg}
      # Accounts.Repo
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Accounts.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
