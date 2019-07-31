defmodule Pizzas do
  @moduledoc """
  Documentation for Pizzas.
  """

  defdelegate create_pizza_with_toppings(user_info_or_err, pizza_name, topping_id_list), to: Pizzas.Impl
  defdelegate add_toppings_to_pizza(permission, pizza_id, topping_id_list), to: Pizzas.Impl
  defdelegate retrieve_pizza_by_id(id), to: Pizzas.Impl
  defdelegate retrieve_pizza_by_name(name), to: Pizzas.Impl
  defdelegate retrieve_pizza_toppings_by_pizzaid(pizza_id), to: Pizzas.Impl
  defdelegate retrieve_pizzas, to: Pizzas.Impl
  defdelegate delete_pizza(permission, id), to: Pizzas.Impl
  defdelegate create_topping(permission, name), to: Pizzas.Impl
  defdelegate fetch_toppings_list(permission), to: Pizzas.Impl
  defdelegate retrieve_toppings, to: Pizzas.Impl
  defdelegate delete_topping(permission, id), to: Pizzas.Impl
  # Had to expose this if I wanted to test that a topping is being created.
  defdelegate retrieve_topping_by_id(id), to: Pizzas.Impl
end
