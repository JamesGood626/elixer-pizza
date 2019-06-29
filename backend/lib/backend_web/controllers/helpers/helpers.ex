defmodule Backend.Helpers do
  use BackendWeb, :controller

  def set_session_data(conn, nil), do: conn
  def set_session_data(conn, session_data), do: put_session(conn, :session_token, session_data)

  def send_client_response(conn, status, payload) do
    conn
    |> put_status(status)
    |> json(%{data: payload})
  end
end
