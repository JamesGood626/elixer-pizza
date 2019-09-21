defmodule BackendWeb.ToppingControllerTest do
  use BackendWeb.ConnCase
  alias Dbstore.{Repo, Permissions, Topping}
  alias Accounts
  alias Pizzas

  @topping_one_input %{
    name: "Maple Syrup"
  }

  @topping_two_input %{
    name: "Sardines"
  }

  @admin_user_input %{
    username: "boss_user",
    password: "boss_password"
  }

  @valid_signup_input %{
    username: "user_one",
    password: "user_one_password"
  }

  @create_topping_success_response %{
    "data" => %{
      "message" => "Topping successfully created!"
    }
  }

  @create_topping_duplicate_fail_response %{
    "data" => %{
      "message" => %{
        "name" => ["That topping name is already taken"]
      }
    }
  }

  @list_toppings_success_response %{
    "data" => [
      %{"name" => "Maple Syrup"},
      %{"name" => "Sardines"}
    ]
  }

  @delete_topping_success_response %{
    "data" => %{ "message" => "Topping successfully deleted" }
  }

  # "setup_all" is called once per module before any test runs
  setup_all do
    Repo.insert(%Permissions{name: "PIZZA_APPLICATION_MAKER"})
    Repo.insert(%Permissions{name: "PIZZA_OPERATION_MANAGER"})
    Repo.insert(%Permissions{name: "PIZZA_CHEF"})
    # Designated Admin
    Accounts.signup_pizza_app_maker(@admin_user_input)

    # handles clean up after all tests have run
    on_exit(fn ->
      Repo.delete_all("user_permissions")
      Repo.delete_all("users")
      Repo.delete_all("permissions")
      Repo.delete_all("toppings")
    end)
  end

  # "setup" is called before each test
  setup do
    # This is the key to ensuring that data inserted into the DB
    # will be cleared after each test run.
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(Dbstore.Repo)
  end

  describe "POST /api/toppings" do
    test "user logged in w/ PIZZA_APPLICATION_MAKER permission can create a topping", %{conn: conn} do
      conn = post(conn, "/api/login", @admin_user_input)
      conn = post(conn, "/api/toppings", @topping_one_input)
      %{"data" => %{"topping_id" => id}} = json_response(conn, 201)
      assert @create_topping_success_response = json_response(conn, 201)
      assert %Dbstore.Topping{name: "Maple Syrup"} = Pizzas.retrieve_topping_by_id(id)
    end

    test "topping creation fails if name is already taken", %{conn: conn} do
      conn = post(conn, "/api/login", @admin_user_input)
      conn = post(conn, "/api/toppings", @topping_one_input)
      conn = post(conn, "/api/toppings", @topping_one_input)
      assert @create_topping_duplicate_fail_response === json_response(conn, 400)
    end
  end

  describe "GET /api/toppings" do
    test "retrieves a list of toppings", %{conn: conn} do
      conn = post(conn, "/api/login", @admin_user_input)
      conn = post(conn, "/api/toppings", @topping_one_input)
      conn = post(conn, "/api/toppings", @topping_two_input)
      conn = get(conn, "/api/toppings")
      assert @list_toppings_success_response = json_response(conn, 200)
    end
  end

  describe "DELETE /api/toppings/:id" do
    test "user may delete a topping", %{conn: conn} do
      conn = post(conn, "/api/login", @admin_user_input)
      conn = post(conn, "/api/toppings", @topping_one_input)
      %{"data" => %{"topping_id" => id}} = json_response(conn, 201)
      conn = delete(conn, "/api/toppings/#{id}")
      assert @delete_topping_success_response === json_response(conn, 200)
    end
  end
end
