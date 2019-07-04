defmodule Mix.Tasks.Bootstrap do
  use Mix.Task

  @doc """
    Gets the project ready for development/testing.

    Sets up Dbstore project
      - mix deps.get
      - mix ecto.create
      - mix ecto.migrate
      - mix compile

    Sets up Auth, Accounts, Pizza mix projects
      - mix deps.get
      - mix compile
  """
  def run(_) do
    bootstrap_dbstore()
    |> bootstrap_projects
  end

  def bootstrap_dbstore() do
    IO.puts("Setting up dbstore...")
    System.cmd("make", ["bootstrap_dbstore"])
    IO.puts("dbstore bootstrapped!")
    {:ok, ["bootstrap_auth", "bootstrap_accounts", "bootstrap_pizzas"]}
  end

  def bootstrap_projects({:ok, [project | []]}) do
    IO.puts("Setting up #{project}...")
    System.cmd("make", [project])
    IO.puts("#{project} bootstrapped!")
  end

  def bootstrap_projects({:ok, [project | projects]}) do
    IO.puts("Bootstrapping #{project}...")
    System.cmd("make", [project])
    IO.puts("#{project} bootstrapped!")
    bootstrap_projects({:ok, projects})
  end
end
