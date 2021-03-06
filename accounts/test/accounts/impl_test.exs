defmodule ImplTest do
  use ExUnit.Case
  alias Ecto.Changeset
  alias Accounts.Impl
  alias Dbstore.{Repo, User, Permissions, UserPermissions}

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
    status: 201
  }

  @invalid_username_response %{
    payload: %{
      errors: %{username: ["should be at least 3 character(s)"]}
    },
    status: 400
  }

  @duplicate_user_response %{
    payload: %{
      errors: %{username: ["That username is already taken"]}
    },
    status: 400
  }

  @valid_login_response %{
    payload: %{
      message: "You've successfully logged in!",
      username: "user_one"
    },
    status: 201
  }

  # "setup_all" is called once per module before any test runs
  setup_all do
    {:ok, %Permissions{id: pizza_ops_manager_id}} =
      Repo.insert(%Permissions{name: "PIZZA_OPERATION_MANAGER"})

    {:ok, %Permissions{id: pizza_chef_id}} = Repo.insert(%Permissions{name: "PIZZA_CHEF"})

    # handles clean up after all tests have run
    on_exit(fn ->
      Repo.delete_all("permissions")
    end)

    :ok
  end

  # "setup" is called before each test
  setup do
    # This is the key to ensuring that data inserted into the DB
    # will be cleared after each test run.
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(Dbstore.Repo)
  end

  describe "signup_pizza_ops_manager/1" do
    test "inserts a user with PIZZA_OPERATION_MANAGER permissions if provided with valid data" do
      assert @valid_creation_response = Accounts.signup_pizza_ops_manager(@valid_input)
      user = Impl.retrieve_user_by_username(@valid_input[:username])
      permission = Impl.retrieve_user_permissions_by_userid(user.id)
      assert permission === "PIZZA_OPERATION_MANAGER"
      # TODO: Once I assing UUIDs or something I'll add this back into the test case.
      # assert %User{id: id} = Accounts.retrieve_user_by_id(id)
    end

    test "fails to insert a user with a duplicate username" do
      Accounts.signup_pizza_ops_manager(@user_two)

      assert @duplicate_user_response = Accounts.signup_pizza_ops_manager(@user_two)
    end

    test "fails to insert user with an invalid username" do
      assert @invalid_username_response = Accounts.signup_pizza_ops_manager(@invalid_input)
    end
  end

  describe "signup_pizza_chef/1" do
    test "inserts a user if provided with valid data" do
      assert @valid_creation_response = Accounts.signup_pizza_chef(@valid_input)
      user = Impl.retrieve_user_by_username(@valid_input[:username])
      permission = Impl.retrieve_user_permissions_by_userid(user.id)
      assert permission === "PIZZA_CHEF"
      # TODO: Once I assing UUIDs or something I'll add this back into the test case.
      # assert %User{id: id} = Accounts.retrieve_user_by_id(id)
    end

    test "fails to insert a user with a duplicate username" do
      Accounts.signup_pizza_chef(@user_two)

      assert @duplicate_user_response = Accounts.signup_pizza_chef(@user_two)
    end

    test "fails to insert user with an invalid username" do
      assert @invalid_username_response = Accounts.signup_pizza_chef(@invalid_input)
    end
  end

  describe "login/1" do
    test "will return successful login response when provided a valid username & password" do
      Accounts.signup_pizza_chef(@valid_input)
      response = Impl.login(@valid_input)
      assert @valid_login_response = response
    end
  end
end
