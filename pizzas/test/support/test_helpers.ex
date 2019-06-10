defmodule Pizzas.TestHelpers do
  alias Pizzas

  @doc """
    Takes a range: 1..3
    In order to create pizzas in the DB for ensuring that
    they are successfully retrieved from the DB.
  """
  def create_pizzas_fixture(amount = %Range{}) do
    Enum.map(amount, fn _ -> "pizza#{System.unique_integer([:positive])}" end)
    |> Enum.map(fn name -> Pizzas.create_pizza(name))
  end
end
