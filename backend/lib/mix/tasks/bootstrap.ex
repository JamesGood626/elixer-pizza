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
    setup_dbstore()
    |> setup_projects
  end

  def setup_dbstore() do
    IO.puts("Setting up dbstore...")
    System.cmd("make", ["setup_dbstore"])
    IO.puts("dbstore setup!")
    {:ok, ["setup_auth", "setup_accounts", "setup_pizzas"]}
  end

  def setup_projects({:ok, [project | []]}) do
    IO.puts("Setting up #{project}...")
    System.cmd("make", [project])
    IO.puts("#{project} setup!")
  end

  def setup_projects({:ok, [project | projects]}) do
    IO.puts("Setting up #{project}...")
    System.cmd("make", [project])
    IO.puts("#{project} setup!")
    setup_projects({:ok, projects})
  end
end
