defmodule Accounts do
  @moduledoc """
  Documentation for Accounts.
  """

  @doc """
  Hello world.

  ## Examples

      iex> Accounts.hello()
      :world

  """
  def hello do
    :world
  end

  alias Accounts.Repo
  alias Accounts.User

  def create_user(username),
    do: Repo.insert!(%User{username: username, password_hash: "test_test"})

  def retrieve_user_by_id(id), do: Repo.get!(User, id)
  def retrieve_user_by_username(username), do: Repo.get!(User, username)
end
