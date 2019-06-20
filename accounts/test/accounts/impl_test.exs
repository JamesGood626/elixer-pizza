defmodule ImplTest do
  use ExUnit.Case
  alias Ecto.Changeset
  alias Accounts.Impl
  alias Dbstore.User
  # Not a viable option.
  # doctest Accounts.Impl

  @valid_input %{
    username: "user_one",
    password: "user_one_password"
  }
  @invalid_input %{
    username: "da",
    password: "da_password"
  }
  @user_two %{
    username: "user_two",
    password: "user_two_password"
  }

  @duplicate_user_errors [
    username:
      {"That username is already taken",
       [constraint: :unique, constraint_name: "users_username_index"]}
  ]

  @invalid_username_errors [
    username:
      {"should be at least %{count} character(s)",
       [count: 3, validation: :length, kind: :min, type: :string]}
  ]

  setup do
    # This is the key to ensuring that data inserted into the DB
    # will be cleared after each test run.
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(Dbstore.Repo)
  end

  describe "create_user/1" do
    test "inserts a user if provided with valid data" do
      assert {:ok, %User{id: id}} = Accounts.create_user(@valid_input)
      assert %User{id: id} = Accounts.retrieve_user_by_id(id)
    end

    test "fails to insert a user with a duplicate username" do
      assert {:ok, %User{id: id}} = Accounts.create_user(@user_two)

      assert {:error,
              %Changeset{
                valid?: false,
                errors: duplicate_user_errors
              }} = Accounts.create_user(@user_two)
    end

    test "fails to insert user with an invalid username" do
      assert {:error,
              %Changeset{
                valid?: false,
                changes: @invalid_input,
                errors: @invalid_username_errors
              }} = Accounts.create_user(@invalid_input)
    end
  end
end
