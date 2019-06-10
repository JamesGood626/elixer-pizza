defmodule Accounts.Impl do
  @moduledoc """
  Documentation for Accounts.Impl
  """
  alias Dbstore.Repo
  alias Dbstore.User

  @doc """
  Creates a new user.

  ## Examples

      iex> Accounts.Impl.create_user(%{username: "Mario", password_hash: "test_password_hash"})
      %Dbstore.User{
              __meta__: #Ecto.Schema.Metadata<:loaded, "users">,
              id: 5,
              inserted_at: ~N[2019-06-08 03:29:08],
              password: nil,
              password_hash: "test_test",
              permissions: #Ecto.Association.NotLoaded<association :permissions is not loaded>,
              updated_at: ~N[2019-06-08 03:29:08],
              username: "Mario"
            }
  """
  def create_user(params) do
    %User{}
    |> User.changeset(params)
    |> Repo.insert()
  end

  def retrieve_user_by_id(id), do: Repo.get!(User, id)

  def retrieve_user_by_username(username), do: Repo.get!(User, username)
end
