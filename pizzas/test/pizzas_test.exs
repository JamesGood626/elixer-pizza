defmodule PizzasTest do
  use ExUnit.Case, async: true
  alias Pizzas

  setup do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(Pizzas.Repo)
  end

  test "create new pizza" do
    pizza = Pizzas.create_pizza("Cheese")
    new_pizza = Pizzas.retrieve_pizza_by_id(pizza.id)
    assert new_pizza.name === "Cheese"
  end

  test "retrieve all pizzas" do
    Pizzas.create_pizza("Supreme")
    Pizzas.create_pizza("Nacho")
    Pizzas.create_pizza("Veggie")
    pizzas = Pizzas.retrieve_pizzas()
    assert length(pizzas) === 4
  end

  # test "update pizza" do

  # end

  # test "delete pizza" do

  # end

  # test "duplicate pizza creation fails" do

  # end
end
