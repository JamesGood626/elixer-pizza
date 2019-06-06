defmodule PizzaApp.Pizza do
  use Ecto.Schema

  schema "pizzas" do
    field :name, :string
    timestamps()

    many_to_many :toppings, PizzaApp.Toppings, join_through: "pizza_toppings"
  end
end
