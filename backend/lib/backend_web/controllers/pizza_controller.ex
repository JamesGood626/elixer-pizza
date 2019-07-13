defmodule BackendWeb.PizzaController do
  use BackendWeb, :controller
  import Backend.AuthPlug
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

    %{current_user: current_user} = conn.assigns
    %{status: status, payload: payload} =
      with {user_id, permission} <- Accounts.retrieve_user_with_permission(current_user),
            @create_pizza_success_response <- Pizzas.create_pizza_with_toppings({user_id, permission}, name, topping_ids)
          do
            @create_pizza_success_response
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
end
