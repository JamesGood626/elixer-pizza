defmodule Dbstore.Pizza do
  use Ecto.Schema
  import Ecto.Changeset

  schema "pizzas" do
    field(:name, :string)
    timestamps()

    many_to_many(:toppings, Dbstore.Toppings, join_through: "pizza_toppings", on_delete: :delete_all)
  end

  def changeset(pizza, params \\ %{}) do
    pizza
    |> cast(params, [:name])
    |> validate_length(:name, min: 3, max: 40)
    |> unsafe_validate_unique([:name], Dbstore.Repo, message: "That pizza name is already taken")
    |> unique_constraint(:name)
  end
end
