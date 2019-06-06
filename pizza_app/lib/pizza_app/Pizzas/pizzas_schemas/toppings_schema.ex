defmodule PizzaApp.Toppings do
  use Ecto.Schema

  schema "toppings" do
    field :name, :string
    timestamps()

    many_to_many :pizzas, PizzaApp.Pizza, join_through: "pizza_toppings"
  end
end
