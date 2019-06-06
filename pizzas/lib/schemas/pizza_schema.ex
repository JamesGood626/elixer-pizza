defmodule Pizzas.Pizza do
  use Ecto.Schema

  schema "pizzas" do
    field(:name, :string)
    timestamps()

    many_to_many(:toppings, Pizzas.Toppings, join_through: "pizza_toppings")
  end
end
