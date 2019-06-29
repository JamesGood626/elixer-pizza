defmodule Dbstore.Pizza do
  use Ecto.Schema
  import Ecto.Changeset

  schema "pizzas" do
    field(:name, :string)
    field(:user_id, :id)
    timestamps()

    belongs_to(:users, Dbstore.User)
    many_to_many(:toppings, Dbstore.Toppings, join_through: "pizza_toppings")
  end

  def changeset(pizza, params \\ %{}) do
    pizza
    |> cast(params, [:name, :user_id])
    |> validate_required([:name, :user_id])
    |> validate_length(:name, min: 3, max: 40)
    |> unsafe_validate_unique([:name], Dbstore.Repo, message: "That pizza name is already taken")
    |> unique_constraint(:name)
  end
end
