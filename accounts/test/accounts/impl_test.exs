defmodule ImplTest do
  use ExUnit.Case
  alias Ecto.Changeset
  alias Accounts.Impl
  alias Dbstore.User

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

  @valid_creation_response %{
    payload: %{
      message: "You've successfully signed up!",
      username: "user_one"
    },
    status: 200
  }

  @invalid_username_response %{
    payload: %{
      errors: %{username: ["should be at least 3 character(s)"]}
    },
    status: 202
  }

  @duplicate_user_response %{
    payload: %{
      errors: %{username: ["That username is already taken"]}
    },
    status: 202
  }

  # @duplicate_user_errors [
  #   username:
  #     {"That username is already taken",
  #      [constraint: :unique, constraint_name: "users_username_index"]}
  # ]

  # @invalid_username_errors [
  #   username:
  #     {"should be at least %{count} character(s)",
  #      [count: 3, validation: :length, kind: :min, type: :string]}
  # ]

  setup do
    # This is the key to ensuring that data inserted into the DB
    # will be cleared after each test run.
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(Dbstore.Repo)
  end

  describe "signup_user/1" do
    test "inserts a user if provided with valid data" do
      assert @valid_creation_response = Accounts.signup_user(@valid_input)

      # assert %User{id: id} = Accounts.retrieve_user_by_id(id)
    end

    test "fails to insert a user with a duplicate username" do
      Accounts.signup_user(@user_two)

      assert @duplicate_user_response = Accounts.signup_user(@user_two)
    end

    test "fails to insert user with an invalid username" do
      assert invalid_username_response = Accounts.signup_user(@invalid_input)
    end
  end
end

# %{status: 200, payload: %{message: "You've successfully signed up!", username: username}}
# %{status: 202, payload: %{errors: errors}}
