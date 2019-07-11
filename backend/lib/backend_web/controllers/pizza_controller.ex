defmodule BackendWeb.PizzaController do
  use BackendWeb, :controller
  import Backend.AuthPlug
  alias Backend.Helpers
  alias Pizzas
  alias Accounts

  plug(:authorize_user)

  def create_pizza(conn, %{"name" => name, "topping_ids" => topping_ids}) do
    IO.puts("THE CONN.ASSIGNS")
    IO.inspect(conn.assigns)

    %{status: status, payload: payload} =
      conn
      |> valid_session?(conn.assigns)
      |> Pizzas.create_pizza_with_toppings(name, topping_ids)

    # TODO: See if it wouldn't be a security issue
    # to include user id's on the conn.assigns

    conn |> Helpers.send_client_response(status, payload)
  end

  def valid_session?(conn, %{current_user: username}) do
    case username do
      nil ->
        conn |> Helpers.send_client_response(400, %{message: "Invalid session"})

      _ ->
        Accounts.retrieve_user_with_permission(username)
    end
  end

  # I do believe that these checks should live closer to the pizza domain, considering
  # these are business rules which pertain strictly to which permissions may perform
  # which actions on the pizza model.
  # TODO: Check to see what the potential error case of the ecto query could be
  # def valid_permission?(action, {user_id, permission = "PIZZA_APPLICATION_MAKER"}), do: user_id

  # def valid_permission?(_) do
  #   {:error, %{payload: %{message: "You're unable to perform that action."}, status: 400}}
  # end
end
