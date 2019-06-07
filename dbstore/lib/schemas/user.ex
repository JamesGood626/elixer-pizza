defmodule Dbstore.User do
  use Ecto.Schema
  # use Ecto.Changeset

  schema "users" do
    field(:username, :string)
    field(:password, :string, virtual: true)
    field(:password_hash, :string)
    timestamps()

    many_to_many(:permissions, Dbstore.Permissions, join_through: "user_permissions")
  end

  # def changeset(user, params \\ %{}) do
  #   user
  #   |> cast(params, [:username])
  #   |> validate_required([:username])
  # end
end
