defmodule BackendWeb.UserController do
  use BackendWeb, :controller
  alias Accounts

  def signup(conn, %{username: username, password: password}) do
    user = Accounts.create_user("James")

    %{username: username} =
      Accounts.retrieve_user_by_id(user.id)
      |> Map.from_struct()
      |> IO.inspect()

    json(conn, %{message: "success", data: %{username: username}})
  end
end
