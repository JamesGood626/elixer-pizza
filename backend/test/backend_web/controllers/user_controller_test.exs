defmodule BackendWeb.UserControllerTest do
  use BackendWeb.ConnCase
  alias Dbstore.{Repo, Permissions}

  # TODO:
  # Create a setup function that creates a second user
  # to reduce amount of requests for user setup.
  @valid_input %{
    username: "user_one",
    password: "user_one_password"
  }

  @signup_success_response %{
    "data" => %{
      "message" => "You've successfully signed up!",
      "username" => "user_one"
    }
  }
  @login_success_response %{
    "data" => %{
      "message" => "You've successfully logged in!",
      "username" => "user_one"
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

  test "GET /api/csrf", %{conn: conn} do
    conn = get(conn, "/api/csrf")
    %{"csrf_token" => csrf_token} = json_response(conn, 200)
    assert String.length(csrf_token) === 56
  end

  test "POST /api/signup_pizza_ops_manager", %{conn: conn} do
    conn = post(conn, "/api/signup_pizza_ops_manager", @valid_input)
    assert @signup_success_response = json_response(conn, 201)

    assert %{
             "session_token" => %{
               expiry: expiry,
               remember_token: remember_token,
               username: "user_one"
             }
           } = conn.private.plug_session

    assert 44 === String.graphemes(remember_token) |> length()
    # Make assertions that expiry greater than whatever desired session length
  end

  test "POST /api/signup_pizza_chef", %{conn: conn} do
    conn = post(conn, "/api/signup_pizza_chef", @valid_input)
    assert @signup_success_response = json_response(conn, 201)

    assert %{
             "session_token" => %{
               expiry: expiry,
               remember_token: remember_token,
               username: "user_one"
             }
           } = conn.private.plug_session

    assert 44 === String.graphemes(remember_token) |> length()
  end

  test "POST /api/login", %{conn: conn} do
    conn = post(conn, "/api/signup_pizza_chef", @valid_input)
    conn = post(conn, "/api/login", @valid_input)
    assert @login_success_response = json_response(conn, 201)

    assert %{
             "session_token" => %{
               expiry: expiry,
               remember_token: remember_token,
               username: "user_one"
             }
           } = conn.private.plug_session

    assert 44 === String.graphemes(remember_token) |> length()
  end

  test "POST /api/logout", %{conn: conn} do
    conn = post(conn, "/api/signup_pizza_chef", @valid_input)
    conn = post(conn, "/api/login", @valid_input)
    conn = post(conn, "/api/logout")
    assert %{} === conn.private.plug_session
  end
end
