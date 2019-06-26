defmodule BackendWeb.UserController do
  use BackendWeb, :controller
  alias Accounts

  def signup_pizza_ops_manager(conn, %{"username" => username, "password" => password}) do
    %{status: status, payload: payload, session_data: session_data} =
      Accounts.signup_pizza_ops_manager(%{username: username, password: password})

    set_session_data(conn, session_data) |> send_client_response(status, payload)
  end

  def signup_pizza_chef(conn, %{"username" => username, "password" => password}) do
    %{status: status, payload: payload, session_data: session_data} =
      Accounts.signup_pizza_chef(%{username: username, password: password})

    set_session_data(conn, session_data) |> send_client_response(status, payload)
  end

  def login(conn, %{"username" => username, "password" => password}) do
    %{status: status, payload: payload, session_data: session_data} =
      Accounts.login(%{username: username, password: password})

    # body_params and params still contain the username and password
    # that was sent on the request... AFTER the client receives the response.
    # Is this bad?
    # lines 27 and 28 clear them:
    # conn = Map.put(conn, :body_params, %{})
    # conn = Map.put(conn, :params, %{})
    set_session_data(conn, session_data) |> send_client_response(status, payload)
  end

  def logout(conn, _params) do
    conn
    |> delete_session(:session_token)
    |> send_client_response(200, %{message: "You've successfully logged out!"})
  end

  defp set_session_data(conn, session_data), do: put_session(conn, :session_token, session_data)
  defp set_session_data(conn, nil), do: conn

  def send_client_response(conn, status, payload) do
    conn
    |> put_status(status)
    |> json(%{data: payload})
  end
end
