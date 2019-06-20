defmodule BackendWeb.UserController do
  use BackendWeb, :controller
  alias Accounts

  def signup(conn, %{"username" => username, "password" => password}) do
    %{status: status, payload: payload} =
      Accounts.signup_user(%{username: username, password: password})

    IO.puts("payload returned from signup_user")
    IO.inspect(payload)

    conn
    |> put_status(status)
    |> json(%{data: payload})
  end
end
