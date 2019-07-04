defmodule Mix.Tasks.Recompile do
  use Mix.Task

  @doc """
    Recompiles the project for development/testing.

    Recompiles up Dbstore project
      - mix clean
      - mix compile

    Recompiles up Auth, Accounts, Pizza mix projects
      - mix clean
      - mix compile
  """
  def run(_) do
    recompile_dbstore()
    |> recompile_projects
  end

  def recompile_dbstore() do
    IO.puts("Recompiling up dbstore...")
    System.cmd("make", ["recompile_dbstore"])
    IO.puts("dbstore recompiled!")
    {:ok, ["recompile_auth", "recompile_accounts", "recompile_pizzas"]}
  end

  def recompile_projects({:ok, [project | []]}) do
    IO.puts("Recompiling up #{project}...")
    System.cmd("make", [project])
    IO.puts("#{project} recompiled!")
  end

  def recompile_projects({:ok, [project | projects]}) do
    IO.puts("Recompiling #{project}...")
    System.cmd("make", [project])
    IO.puts("#{project} recompiled!")
    recompile_projects({:ok, projects})
  end
end
