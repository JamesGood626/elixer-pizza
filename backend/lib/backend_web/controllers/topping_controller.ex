defmodule BackendWeb.ToppingController do
  use BackendWeb, :controller
  import Backend.AuthPlug
  alias Backend.Helpers
  alias Pizzas
  alias Accounts

  plug(:authorize_user)

  @permission_denied_response %{
    status: 400,
    payload: %{
      message: "You're unable to perform that action."
    }
  }

  @create_topping_success_response %{
    status: 201,
    payload: %{
      message: "Topping successfully created!"
    }
  }

  @create_topping_duplicate_fail_response %{
    status: 400,
    payload: %{
      message: %{
        name: ["That topping name is already taken"]
      }
    }
  }

  def create_topping(conn, %{"name" => name}) do
    %{current_user: current_user} = conn.assigns
    %{status: status, payload: payload} =
      with {user_id, permission} <- Accounts.retrieve_user_with_permission(current_user),
            {:ok, id} <- Pizzas.create_topping(permission, name)
          do
            {_, response} = @create_topping_success_response |> get_and_update_in([:payload, :topping_id], &{&1, id})
            response
          else
            {:error, response = @permission_denied_response} -> response
            {:error, response = @create_topping_duplicate_fail_response} -> response
            _ -> %{status: 400, payload: %{message: "Whoops, something went wrong."}}
          end

    conn |> Helpers.send_client_response(status, payload)
  end
end
