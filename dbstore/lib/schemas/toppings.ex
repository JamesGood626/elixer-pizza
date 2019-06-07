defmodule Dbstore.Toppings do
  use Ecto.Schema

  schema "toppings" do
    field(:name, :string)
    timestamps()

    many_to_many(:dbstore, Dbstore.Pizza, join_through: "pizza_toppings")
  end
end
