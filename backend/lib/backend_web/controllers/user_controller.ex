defmodule BackendWeb.UserController do
  use BackendWeb, :controller
  alias Accounts

  def signup_pizza_ops_manager(conn, %{"username" => username, "password" => password}) do
    %{status: status, payload: payload} =
      Accounts.signup_pizza_ops_manager(%{username: username, password: password})

    conn
    |> put_status(status)
    |> json(%{data: payload})
  end

  def signup_pizza_chef(conn, %{"username" => username, "password" => password}) do
    %{status: status, payload: payload} =
      Accounts.signup_pizza_chef(%{username: username, password: password})

    conn
    |> put_status(status)
    |> json(%{data: payload})
  end
end
