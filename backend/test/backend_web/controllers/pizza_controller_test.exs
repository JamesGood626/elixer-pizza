defmodule BackendWeb.PizzaControllerTest do
  use BackendWeb.ConnCase
  alias Dbstore.{Repo, Permissions}

  @valid_input %{
    name: "Pepperoni Pineapple"
  }

  @valid_signup_input %{
    username: "user_one",
    password: "user_one_password"
  }

  @create_pizza_success_response %{
    "data" => %{
      "message" => "Pizza successfully created!"
    }
  }

  # "setup_all" is called once per module before any test runs
  setup_all do
    Repo.insert(%Permissions{name: "PIZZA_OPERATION_MANAGER"})
    Repo.insert(%Permissions{name: "PIZZA_CHEF"})

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

  # TODO: setup a user that's logged in for the duration of this test suite.
  describe "POST /api/pizza" do
    test "user can create a pizza", %{conn: conn} do
      conn = post(conn, "/api/signup_pizza_ops_manager", @valid_signup_input)
      conn = post(conn, "/api/pizza", @valid_input)
      assert @create_pizza_success_response = json_response(conn, 201)
    end

    test "pizza creation fails if name is already taken", %{conn: conn} do
      conn = post(conn, "/api/signup_pizza_ops_manager", @valid_signup_input)
      conn = post(conn, "/api/pizza", @valid_input)
      conn = post(conn, "/api/pizza", @valid_input)
      assert "it fails" = json_response(conn, 201)
    end
  end
end
