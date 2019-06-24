defmodule BackendWeb.UserController do
  use BackendWeb, :controller
  alias Accounts

  def signup_pizza_ops_manager(conn, %{"username" => username, "password" => password}) do
    %{status: status, payload: payload, session_data: session_data} =
      Accounts.signup_pizza_ops_manager(%{username: username, password: password})

    set_session_data(conn, session_data)
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

  defp set_session_data(conn, session_data), do: put_session(conn, :session_token, session_data)
  defp set_session_data(conn, nil), do: conn
end
