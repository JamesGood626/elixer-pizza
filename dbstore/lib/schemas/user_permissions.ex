defmodule Dbstore.UserPermissions do
  use Ecto.Schema

  schema "user_permissions" do
    field(:user_id, :id)
    field(:permission_id, :id)
    timestamps()

    belongs_to(:users, Dbstore.User)
    belongs_to(:permissions, Dbstore.Permissions)
  end
end
