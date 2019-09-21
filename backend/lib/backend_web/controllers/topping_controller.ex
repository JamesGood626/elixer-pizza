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
      # topping_id inserted here from inside controller
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
      # TODO: Remember that you need to do some refactor this user_with_permission into
      #       the auth plug or something so that this with block may be moved into Pizzas.Impl
      with {_user_id, permission} <- Accounts.retrieve_user_with_permission(current_user),
            {:ok, payload = @create_topping_success_response} <- Pizzas.create_topping(permission, name)
          do
            payload
          else
            {:error, response = @permission_denied_response} -> response
            {:error, response = @create_topping_duplicate_fail_response} -> response
            _ -> %{status: 400, payload: %{message: "Whoops, something went wrong."}}
          end

    conn |> Helpers.send_client_response(status, payload)
  end

  def list_toppings(conn, _) do
    %{current_user: current_user} = conn.assigns
    %{status: status, payload: payload} =
      with {_user_id, permission} <- Accounts.retrieve_user_with_permission(current_user),
           topping_list = Pizzas.fetch_toppings_list(permission)
        do
          %{ status: 200, payload: topping_list }
        else
          {:error, response = @permission_denied_response} -> response
          _ -> %{status: 400, payload: %{message: "Whoops, something went wrong."}}
        end

    conn |> Helpers.send_client_response(status, payload)
  end

  def delete_topping(conn = %Plug.Conn{params: %{"id" => id}}, _) do
    %{current_user: current_user} = conn.assigns
    %{status: status, payload: payload} =
      with {_user_id, permission} <- Accounts.retrieve_user_with_permission(current_user),
            # Something I would change is to create a better response (human readable) for this,
            # rather than the standard elixir function's return value.
           {1, _} = Pizzas.delete_topping(permission, id)
        do
          %{status: 200, payload: %{message: "Topping successfully deleted"}}
        else
          {:error, response = @permission_denied_response} -> response
          _ -> %{status: 400, payload: %{message: "Whoops, something went wrong."}}
        end

    conn |> Helpers.send_client_response(status, payload)
  end
end
