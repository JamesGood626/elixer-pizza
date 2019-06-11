defmodule Dbstore.User do
  use Ecto.Schema
  import Ecto.Changeset

  schema "users" do
    field(:username, :string)
    field(:password, :string, virtual: true)
    field(:password_hash, :string)
    timestamps()

    many_to_many(:permissions, Dbstore.Permissions, join_through: "user_permissions")
  end

  def changeset(user, params \\ %{}) do
    user
    |> cast(params, [:username, :password])
    |> validate_required([:username, :password])
    |> validate_length(:username, min: 3, max: 20)
    |> validate_length(:password, min: 8, max: 50)
    |> put_pass_hash
  end

  # usage of the argon2 lib hash password func:
  # Argon2.Base.hash_password("password", "somesaltSOMESALT", [t_cost: 4, m_cost: 18])
  defp put_pass_hash(changeset) do
    IO.puts("the changeset")
    IO.inspect(changeset)

    case changeset do
      _ ->
        put_change(
          changeset,
          :password_hash,
          Argon2.Base.hash_password("password", "somesaltSOMESALT", t_cost: 4, m_cost: 18)
        )
    end
  end

  # This is from the documentation to turn changeset errors into an easier to use map shape:
  # traverse_errors(changeset, fn {msg, opts} ->
  #   Enum.reduce(opts, msg, fn {key, value}, acc ->
  #     String.replace(acc, "%{#{key}}", to_string(value))
  #   end)
  # end)
  # With this map, you can attach error messages to form fields in your UI.

  # You can also create your own custom validation functions that accept a changeset and
  # return a changeset.
end
