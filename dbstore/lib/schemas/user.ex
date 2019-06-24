defmodule Dbstore.User do
  use Ecto.Schema
  import Ecto.Changeset

  # TODO: Best way to generate/set these salts securely?
  @salty "somesaltSOMESALT"

  schema "users" do
    field(:username, :string)
    field(:password, :string, virtual: true)
    field(:password_hash, :string)
    field(:hashed_remember_token, :string)
    timestamps()

    many_to_many(:permissions, Dbstore.Permissions, join_through: "user_permissions")
  end

  def changeset(user, params \\ %{}) do
    user
    |> cast(params, [:username, :password])
    |> validate_required([:username, :password])
    |> validate_length(:username, min: 3, max: 20)
    |> validate_length(:password, min: 8, max: 50)
    |> unsafe_validate_unique([:username], Dbstore.Repo, message: "That username is already taken")
    |> unique_constraint(:username)
    |> put_pass_hash
  end

  defp put_pass_hash(changeset = %Ecto.Changeset{valid?: true, changes: %{password: password}}) do
    put_change(
      changeset,
      :password_hash,
      # TODO: Could utilize Mix.ENV to determine whether in dev, test, prod to determine hash rounds
      Auth.hash_password(password, @salty)
    )
  end

  defp put_pass_hash(changeset), do: changeset

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
