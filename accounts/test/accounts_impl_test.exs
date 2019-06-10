defmodule AccountsImplTest do
  use ExUnit.Case
  # use Accounts.DataCase
  alias Accounts.Impl
  alias Dbstore.User
  # Not a viable option.
  # doctest Accounts.Impl

  @valid_attrs %{
    username: "Mario",
    password_hash: "tne21jknjk1n"
  }

  setup do
    # This is the key to ensuring that data inserted into the DB
    # will be cleared after each test run.
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(Dbstore.Repo)
  end

  describe "create_user/1" do
    test "inserts a user if provided with valid data" do
      assert %User{id: id} = Accounts.create_user(@valid_attrs)
      assert %User{id: id} = Accounts.retrieve_user_by_id(id)
    end

    # test "fails to insert a user with a duplicate username" do
    #   assert %User{id: id} = Accounts.create_user(@valid_attrs)
    #   Accounts.create_user(@valid_attrs)
    #   Accounts.retrieve_user_by_id(id)
    # end
  end
end
