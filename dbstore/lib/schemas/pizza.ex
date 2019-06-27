defmodule Dbstore.Pizza do
  use Ecto.Schema

  schema "pizzas" do
    field(:name, :string)
    field(:user_id, :id)
    timestamps()

    belongs_to(:users, Dbstore.User)
    many_to_many(:toppings, Dbstore.Toppings, join_through: "pizza_toppings")
  end
end
