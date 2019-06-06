defmodule PizzaApp.Permissions do
  use Ecto.Schema

  schema "permissions" do
    field(:name, :string)
    timestamps()

    many_to_many(:users, PizzaApp.User, join_through: "user_permissions")
  end
end
