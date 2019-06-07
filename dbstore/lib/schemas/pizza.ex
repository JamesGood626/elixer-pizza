defmodule Dbstore.Pizza do
  use Ecto.Schema

  schema "pizzas" do
    field(:name, :string)
    timestamps()

    many_to_many(:toppings, Dbstore.Toppings, join_through: "pizza_toppings")
  end
end
