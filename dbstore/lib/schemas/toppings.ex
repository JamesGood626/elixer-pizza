defmodule Dbstore.Toppings do
  use Ecto.Schema
  import Ecto.Changeset

  schema "toppings" do
    field(:name, :string)
    timestamps()

    many_to_many(:dbstore, Dbstore.Pizza, join_through: "pizza_toppings", on_delete: :delete_all)
  end

  def changeset(pizza, params \\ %{}) do
    pizza
    |> cast(params, [:name])
    |> validate_required([:name])
    |> validate_length(:name, min: 3, max: 40)
    |> unsafe_validate_unique([:name], Dbstore.Repo, message: "That topping name is already taken")
    |> unique_constraint(:name)
  end
end
