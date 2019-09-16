defmodule BackendWeb.PizzaController do
  use BackendWeb, :controller
  import Backend.AuthPlug
  import Plug
  alias Backend.Helpers
  alias Pizzas
  alias Accounts

  plug(:authorize_user)

  # NOTE:
  # Think this approach is better if you want to
  # explicitly document all possible responses within the codebase.
  # The only thing to note is to remember the the below status/payload map
  # Will be returned as in a map of %{data: response_data}
  @permission_denied_response %{
    status: 400,
    payload: %{
      message: "You're unable to perform that action."
    }
  }

  @create_pizza_success_response %{
    status: 201,
    payload: %{
      # pizza_id also a key on this response
      message: "Pizza successfully created!"
    }
  }

  @create_pizza_duplicate_fail_response %{
    status: 400,
    payload: %{
      message: %{
        name: ["That pizza name is already taken"]
      }
    }
  }

  @delete_pizza_success_response %{
    status: 200,
    payload: %{
      # deleted_pizza is also a key on this payload, a map containing id and name
      message: "Pizza successfully deleted!"
    }
  }

  def create_pizza(conn, %{"name" => name, "topping_ids" => topping_ids}) do
    # TODO: See if it wouldn't be a security issue
    # to include user id's and permission on the conn.assigns
    # in order to mitigate the retrieve_user_with_permission call
    # inside of every controller... and instead only handle that
    # inside of the authorize_user plug

    # Refactored the pipelining below to be the with statement.
    # Do think the other approach lends itself better to self documentation
    # %{status: status, payload: payload} =
    #   conn.assigns.current_user
    #   |> Accounts.retrieve_user_with_permission()
    #   |> Pizzas.create_pizza_with_toppings(name, topping_ids)

    # TODO:
    # If I was able to refactor to eliminate the need to call retrieve_user_with_permission
    # in this controller (by handling that in the authenticate_user plug)... Then I could
    # Move this with block into the pizzas app instead, and expose one top level create_pizza
    # function there.

    %{current_user: current_user} = conn.assigns
    %{status: status, payload: payload} =
      with {user_id, permission} <- Accounts.retrieve_user_with_permission(current_user),
            response = @create_pizza_success_response <- Pizzas.create_pizza_with_toppings(permission, name, topping_ids)
          do
            response
          else
            {:error, response = @permission_denied_response} -> response
            {:error, response = @create_pizza_duplicate_fail_response} -> response
            _ -> %{status: 400, payload: %{message: "Whoops, something went wrong."}}
          end

    conn |> Helpers.send_client_response(status, payload)
  end

  # I do believe that these checks should live closer to the pizza domain, considering
  # these are business rules which pertain strictly to which permissions may perform
  # which actions on the pizza model.
  # TODO: Check to see what the potential error case of the ecto query could be
  # def valid_permission?(action, {user_id, permission = "PIZZA_APPLICATION_MAKER"}), do: user_id

  # def valid_permission?(_) do
  #   {:error, %{payload: %{message: "You're unable to perform that action."}, status: 400}}
  # end

  def add_toppings(conn, %{"pizza_id" => pizza_id, "topping_id_list" => topping_id_list}) do
    %{current_user: current_user} = conn.assigns
    %{status: status, payload: payload} =
      with {user_id, permission} <- Accounts.retrieve_user_with_permission(current_user),
            @add_toppings_success_response <- Pizzas.add_toppings_to_pizza(permission, pizza_id, topping_id_list)
          do
            @add_toppings_success_response
          else
            {:error, response = @permission_denied_response} -> response
            _ -> %{status: 400, payload: %{message: "Whoops, something went wrong."}}
          end
    conn |> Helpers.send_client_response(status, payload)
  end

  def delete_pizza(conn = %Plug.Conn{params: %{"id" => pizza_id}}, _) do
    %{current_user: current_user} = conn.assigns
    %{status: status, payload: payload} =
      with {user_id, permission} <- Accounts.retrieve_user_with_permission(current_user),
            {:ok, response = @delete_pizza_success_response} <- Pizzas.delete_pizza(permission, pizza_id)
          do
            response
          else
            {:error, response = @permission_denied_response} -> response
            _ -> %{status: 400, payload: %{message: "Whoops, something went wrong."}}
          end
    conn |> Helpers.send_client_response(status, payload)
  end
end
