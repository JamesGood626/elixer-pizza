defmodule Dbstore.Permissions do
  use Ecto.Schema

  schema "permissions" do
    field(:name, :string)
    timestamps()

    many_to_many(:users, Dbstore.User, join_through: "user_permissions")
  end
end
