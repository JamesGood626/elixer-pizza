defmodule Accounts.Permissions do
  use Ecto.Schema

  schema "permissions" do
    field(:name, :string)
    timestamps()

    many_to_many(:users, Accounts.User, join_through: "user_permissions")
  end
end
