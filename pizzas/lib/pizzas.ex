defmodule Pizzas do
  @moduledoc """
  Documentation for Pizzas.
  """

  defdelegate create_pizza(name, user_id), to: Pizzas.Impl
  defdelegate retrieve_pizza_by_id(id), to: Pizzas.Impl
  defdelegate retrieve_pizza_by_name(name), to: Pizzas.Impl
  defdelegate retrieve_pizzas, to: Pizzas.Impl
end
