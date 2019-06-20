defmodule BackendWeb.UserControllerTest do
  use BackendWeb.ConnCase

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

  setup do
    # This is the key to ensuring that data inserted into the DB
    # will be cleared after each test run.
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(Dbstore.Repo)
  end

  test "POST /signup", %{conn: conn} do
    conn = post(conn, "/signup", @valid_input)
    assert @signup_success_response = json_response(conn, 200)
  end
end
