defmodule PizzasImplTest do
  use ExUnit.Case, async: true
  alias Dbstore.{Repo, Pizza, Toppings}
  alias Pizzas

  setup_all do
    Repo.insert(%Toppings{name: "Pineapple"})
    Repo.insert(%Toppings{name: "Sausage"})
    Repo.insert(%Toppings{name: "Jalapenos"})

    # handles clean up after all tests have run
    on_exit(fn ->
      Repo.delete_all("toppings")
    end)

    toppings_id_list =
    Pizzas.retrieve_toppings()
    |> Enum.map(fn topping -> topping.id end)
    {:ok, %{toppings_id_list: toppings_id_list}}
  end

  setup do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(Dbstore.Repo)
  end

  # TODO: Didn't rewrite these tests since one of the last
  # refactors I was doing.
  # would like to unit test create_pizza, but that function
  # should really be private. Look into testing private functions.
  # test "create new pizza" do
  #   pizza = Pizzas.create_pizza("Cheese")
  #   new_pizza = Pizzas.retrieve_pizza_by_id(pizza.id)
  #   assert new_pizza.name === "Cheese"
  # end

  # test "retrieve all pizzas" do
  #   Pizzas.create_pizza("Supreme")
  #   Pizzas.create_pizza("Nacho")
  #   Pizzas.create_pizza("Veggie")
  #   pizzas = Pizzas.retrieve_pizzas()
  #   assert length(pizzas) === 4
  # end

  test "adds toppings to pizza", %{toppings_id_list: topping_id_list} do
    {:ok, %Pizza{id: pizza_id}} = Repo.insert(%Pizza{name: "Pineapple Surprise"})
    assert "1" == add_toppings_to_pizza("PIZZA_CHEF", pizza_id, topping_id_list)
  end

  # test "update pizza" do

  # end

  # test "delete pizza" do

  # end

  # test "duplicate pizza creation fails" do

  # end
end
