defmodule BackendWeb.PizzaControllerTest do
  use BackendWeb.ConnCase
  alias Dbstore.{Repo, Permissions, Toppings}
  alias Pizzas

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
    IO.puts("Current Mix env:")
    IO.inspect(Mix.env())
    # TODO: !! Need to create user w/ P_A_M permission.
    #       didn't want to expose an endpoint for creating
    #       a user w/ this type of permission. So will need to
    #       run a seed so that there's always one available for testing.
    Repo.insert(%Permissions{name: "PIZZA_APPLICATION_MAKER"})
    Repo.insert(%Permissions{name: "PIZZA_OPERATION_MANAGER"})
    Repo.insert(%Permissions{name: "PIZZA_CHEF"})
    Repo.insert(%Toppings{name: "Pineapple"})

    # handles clean up after all tests have run
    on_exit(fn ->
      Repo.delete_all("permissions")
      Repo.delete_all("toppings")
    end)

    [%Toppings{id: id} | _] = Pizzas.retrieve_toppings()
    {:ok, %{topping_ids: [id]}}
  end

  # "setup" is called before each test
  setup do
    # This is the key to ensuring that data inserted into the DB
    # will be cleared after each test run.
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(Dbstore.Repo)
  end

  # TODO: setup a user that's logged in for the duration of this test suite.
  describe "POST /api/pizza" do
    test "user can create a pizza", %{conn: conn, topping_ids: topping_ids} do
      conn = post(conn, "/api/signup_pizza_ops_manager", @valid_signup_input)
      conn = post(conn, "/api/pizza", Map.put(@valid_input, :topping_ids, topping_ids))
      assert @create_pizza_success_response = json_response(conn, 201)
    end

    test "pizza creation fails if name is already taken", %{conn: conn, topping_ids: topping_ids} do
      conn = post(conn, "/api/signup_pizza_ops_manager", @valid_signup_input)
      valid_input = Map.put(@valid_input, :topping_ids, topping_ids)
      conn = post(conn, "/api/pizza", valid_input)
      conn = post(conn, "/api/pizza", valid_input)
      assert @create_pizza_success_response = json_response(conn, 201)
    end
  end
end
