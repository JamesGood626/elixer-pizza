defmodule Pizzas.Toppings do
  use Ecto.Schema

  schema "toppings" do
    field(:name, :string)
    timestamps()

    many_to_many(:pizzas, Pizzas.Pizza, join_through: "pizza_toppings")
  end
end
