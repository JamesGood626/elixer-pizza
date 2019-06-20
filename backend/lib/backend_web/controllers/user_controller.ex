defmodule BackendWeb.UserController do
  use BackendWeb, :controller
  alias Accounts

  def signup(conn, %{"username" => username, "password" => password}) do
    # Will use service function to delegate this logic to.
    # service function will use function clauses to catch {:ok, user}/{:err, changeset}
    {:ok, user} = Accounts.create_user(%{username: username, password: password})
    IO.puts("user returned from create_user")
    IO.inspect(user)

    %{username: username} =
      Accounts.retrieve_user_by_id(user.id)
      |> Map.from_struct()
      |> IO.inspect()

    conn
    |> put_status(200)
    |> json(%{message: "success", data: %{username: username}})
  end
end
