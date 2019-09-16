defmodule BackendWeb.PizzaControllerTest do
  use BackendWeb.ConnCase
  alias Dbstore.{Repo, Permissions, Topping}
  alias Accounts
  alias Pizzas

  @valid_input %{
    name: "Pepperoni Pineapple"
  }

  @admin_user_input %{
    username: "boss_user",
    password: "boss_password"
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

  @create_pizza_duplicate_fail_response %{
    "data" => %{
      "message" => %{
        "name" => ["That pizza name is already taken"]
      }
    }
  }

  # "setup_all" is called once per module before any test runs
  setup_all do
    Repo.insert(%Permissions{name: "PIZZA_APPLICATION_MAKER"})
    Repo.insert(%Permissions{name: "PIZZA_OPERATION_MANAGER"})
    Repo.insert(%Permissions{name: "PIZZA_CHEF"})
    Repo.insert(%{name: "Pineapple"})
    # Designated Admin
    Accounts.signup_pizza_app_maker(@admin_user_input)

    # handles clean up after all tests have run
    on_exit(fn ->
      Repo.delete_all("user_permissions")
      Repo.delete_all("users")
      Repo.delete_all("permissions")
      Repo.delete_all("toppings")
    end)

    [%Topping{id: id} | _] = Pizzas.retrieve_toppings()
    {:ok, %{topping_ids: [id]}}
  end

  # "setup" is called before each test
  setup do
    # This is the key to ensuring that data inserted into the DB
    # will be cleared after each test run.
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(Dbstore.Repo)
  end

  describe "POST /api/pizza" do
    test "user w/ PIZZA_APPLICATION_MAKER permission can create a pizza", %{
      conn: conn,
      topping_ids: topping_ids
    } do
      conn = post(conn, "/api/login", @admin_user_input)
      conn = post(conn, "/api/pizza", Map.put(@valid_input, :topping_ids, topping_ids))
      assert @create_pizza_success_response = json_response(conn, 201)
    end

    test "pizza creation fails if name is already taken", %{conn: conn, topping_ids: topping_ids} do
      conn = post(conn, "/api/login", @admin_user_input)
      valid_input = Map.put(@valid_input, :topping_ids, topping_ids)
      conn = post(conn, "/api/pizza", valid_input)
      conn = post(conn, "/api/pizza", valid_input)
      assert @create_pizza_duplicate_fail_response === json_response(conn, 400)
    end
  end

  describe "DELETE /api/pizza/:id" do
    test "user may delete a pizza", %{conn: conn, topping_ids: topping_ids} do
      conn = post(conn, "/api/login", @admin_user_input)
      valid_input = Map.put(@valid_input, :topping_ids, topping_ids)
      conn = post(conn, "/api/pizza", valid_input)
      %{ "data" => %{ "pizza_id" => pizza_id } } = json_response(conn, 201)
      conn = delete(conn, "/api/pizza/#{pizza_id}")
      %{"data" => %{ "message" => "Pizza successfully deleted!" }} = json_response(conn, 200)
    end
  end
end
