defmodule BackendWeb.PageController do
  use BackendWeb, :controller
  alias Accounts.Repo
  alias Accounts

  def index(conn, _params) do
    render(conn, "index.html")
  end

  def test(conn, _params) do
    user = Accounts.create_user("James")

    %{username: username} =
      Accounts.retrieve_user_by_id(user.id)
      |> Map.from_struct()
      |> IO.inspect()

    # |> Poison.encode!()

    json(conn, %{message: "success", data: %{username: username}})
  end
end
