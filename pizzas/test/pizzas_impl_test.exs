defmodule PizzasImplTest do
  use ExUnit.Case, async: true
  import Ecto.Query
  alias Dbstore.{Repo, Pizza, Toppings, PizzaToppings}
  alias Pizzas

  # Responses
  @toppings_added_response %{
    payload: %{
      message: "Toppings successfully added!"
    },
    status: 201
  }

  @delete_pizza_success_response {:ok, %{
    status: 201,
    payload: %{
      message: "Pizza successfully deleted!",
    }
  }}

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

  test "create new pizza", %{toppings_id_list: topping_id_list} do
    Pizzas.create_pizza_with_toppings("PIZZA_CHEF", "Supreme", topping_id_list)
    [pizza] = Pizzas.retrieve_pizzas()
    assert "Supreme" == pizza.name
  end

  test "retrieve all pizzas", %{toppings_id_list: topping_id_list} do
    Pizzas.create_pizza_with_toppings("PIZZA_CHEF", "Cheese", topping_id_list)
    Pizzas.create_pizza_with_toppings("PIZZA_CHEF", "Nacho", topping_id_list)
    Pizzas.create_pizza_with_toppings("PIZZA_CHEF", "Veggie", topping_id_list)
    pizzas = Pizzas.retrieve_pizzas()
    assert length(pizzas) === 3
  end

  test "creates a pizza" do
    {:ok, %Pizza{id: pizza_id}} = Repo.insert(%Pizza{name: "Supreme"})
    pizza = Pizzas.retrieve_pizza_by_id(pizza_id)
    assert "Supreme" == pizza.name
  end

  test "creates a topping" do
    {:ok, %{ payload: %{ topping_id: id } } } = Pizzas.create_topping("PIZZA_OPERATION_MANAGER", "Olives")
    assert %Dbstore.Toppings{name: "Olives"} = Pizzas.retrieve_topping_by_id(id)
  end

  test "retrieves a list of all toppings" do
    assert [
      %Dbstore.Toppings{name: "Pineapple"},
      %Dbstore.Toppings{name: "Sausage"},
      %Dbstore.Toppings{name: "Jalapenos"}
    ] = Pizzas.retrieve_toppings()
  end

  test "adds toppings to pizza", %{toppings_id_list: topping_id_list} do
    {:ok, %Pizza{id: pizza_id}} = Repo.insert(%Pizza{name: "Pineapple Surprise"})
    assert @toppings_added_response == Pizzas.add_toppings_to_pizza("PIZZA_CHEF", pizza_id, topping_id_list)
    assert ["Pineapple", "Sausage", "Jalapenos"] == Pizzas.retrieve_pizza_toppings_by_pizzaid(pizza_id)
  end

  # test "update pizza" do

  # end

  test "deletes a pizza, and all of its pizza_topping associations", %{toppings_id_list: topping_id_list} do
    {:ok, %Pizza{id: pizza_id}} = Repo.insert(%Pizza{name: "Pineapple Surprise"})
    assert @toppings_added_response === Pizzas.add_toppings_to_pizza("PIZZA_CHEF", pizza_id, topping_id_list)
    assert @delete_pizza_success_response = Pizzas.delete_pizza("PIZZA_CHEF", pizza_id)
    # assert "boom" = from(t in "pizza_toppings", select: t.id) |> Repo.all()
    assert nil === Pizzas.retrieve_pizza_by_id(pizza_id)
  end

  # test "duplicate pizza creation fails" do

  # end
end
