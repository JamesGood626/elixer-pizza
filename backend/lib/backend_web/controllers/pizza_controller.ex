defmodule BackendWeb.PizzaController do
  use BackendWeb, :controller
  import Backend.AuthPlug
  alias Backend.Helpers
  alias Pizzas
  alias Accounts

  plug(:authorize_user)

  # TODO: Unfuck this
  def create_pizza(conn, %{"name" => name}) do
    IO.puts("THE CONN.ASSIGNS")
    IO.inspect(conn.assigns)
    %{current_user: username} = conn.assigns

    # TODO: refactor this garbage (but this is essentially a check that you need to
    # ensure that there's a valid session before running business logic in the controllers.)
    case username do
      nil ->
        conn |> Helpers.send_client_response(400, %{message: "Invalid session"})

      _ ->
        :ok
    end

    # TODO: this is temporary... see if it wouldn't be a security issue
    # to include user id's on the conn.assigns
    user = Accounts.retrieve_user_by_username(username)
    pizza = Pizzas.create_pizza(name, user.id)
    IO.puts("Result of creating pizza")
    IO.inspect(pizza)

    payload = %{message: "Pizza successfully created!"}
    conn |> Helpers.send_client_response(201, payload)
  end
end
