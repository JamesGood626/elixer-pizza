defmodule PizzaApp.User do
  use Ecto.Schema

  schema "users" do
    field :username, :string
    field :password, :string, virtual: true
    field :password_hash, :string
    timestamps()

    many_to_many :permissions, PizzaApp.Permissions, join_through: "user_permissions"
  end
end
