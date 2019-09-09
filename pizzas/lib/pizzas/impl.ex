defmodule Pizzas.Impl do
  @moduledoc """
  Documentation for Pizzas.Impl.
  """
  import Ecto.Query
  alias Ecto.Changeset
  alias Dbstore.Repo
  alias Dbstore.{Pizza, Toppings, PizzaTopping}

  # Permissions
  @pizza_application_maker "PIZZA_APPLICATION_MAKER"
  @pizza_operation_manager "PIZZA_OPERATION_MANAGER"
  @pizza_chef "PIZZA_CHEF"

  # Actions
  @create_pizza "CREATE_PIZZA"
  @add_toppings "ADD_TOPPINGS"
  @list_pizzas "LIST_PIZZAS"
  @delete_pizza "DELETE_PIZZA"
  @list_toppings "LIST_TOPPINGS"
  @delete_topping "DELETE_TOPPING"

  # TODO:
  # - Implement list pizzas final thing.
  # - csrf endpoint ill-advised?
  # - Then refactor. Auth module, and service functions to be cleaner. (Will do this after Frontend is done.)
  # - Tests could be improved by testing that roles which do not have permission to perform an action
  #   receive the correct response. Later.

  # Responses
  @pizza_created_response %{
    payload: %{
      message: "Pizza successfully created!"
    },
    status: 201
  }

  @toppings_added_response %{
    payload: %{
      message: "Toppings successfully added!"
    },
    status: 201
  }

  @bad_request_response %{
    payload: %{
      message: "You're unable to perform that action."
    },
    status: 400
  }

  # TODO:
   # "PIZZA_CHEF"
  # - allowed to see a list of existing pizzas and their toppings
  # - allowed to delete an existing pizza

  @permissions %{
    @create_pizza => [@pizza_application_maker, @pizza_chef],
    @add_toppings => [@pizza_application_maker, @pizza_chef],
    @list_pizzas => [@pizza_application_maker, @pizza_chef],
    @delete_pizza => [@pizza_application_maker, @pizza_chef],
    @create_topping => [@pizza_application_maker, @pizza_operation_manager],
    @list_toppings => [@pizza_application_maker, @pizza_operation_manager],
    @delete_topping => [@pizza_application_maker, @pizza_operation_manager]
  }

  # TODO: This needs to be incorporated into the auth lib
  #       and then passed into whatever functions require
  #       authorization, along with the roles/permissions.
  defp valid_permission?(action, permissions, permission) do
    permissions
    |> Map.get(action, permission)
    |> Enum.any?(fn x -> x === permission end)
    |> case do
      true ->
        :ok
      false ->
        {:error, @bad_request_response}
    end
  end

  def create_pizza_with_toppings(permission, pizza_name, topping_id_list) do
    case @create_pizza |> valid_permission?(@permissions, permission) do
      :ok ->
        create_pizza(pizza_name)
        # TODO: Error handling still needs to occur here.
        |> create_pizza_toppings(topping_id_list)
      {:error, response} ->
        {:error, response}
    end
  end

  def create_pizza(name) do
    %Pizza{}
    |> Pizza.changeset(%{name: name})
    |> Repo.insert()
    |> handle_creation_result()
  end

  # TODO: Make sure you send back the ids of the pizzas when you implement
  # the list pizzas function.
  def delete_pizza(permission, id) do
    case @delete_pizza |> valid_permission?(@permissions, permission) do
      :ok ->
        Repo.get(Pizza, id)
        |> Repo.delete()
        |> format_response(:delete_pizza)

      {:error, response} ->
          {:error, response}
    end
  end

  def create_topping(permission, name) do
    # TODO: Repition going on. Should use an anon func to pass in the action & :ok logic
    # And move the general case stuff out into a separate function.
    case @create_topping |> valid_permission?(@permissions, permission) do
      :ok ->
        %Toppings{}
          |> Toppings.changeset(%{name: name})
          |> Repo.insert()
          |> handle_creation_result()
          |> format_response(:create_topping)
      {:error, response} ->
        {:error, response}
    end
  end

  def fetch_toppings_list(permission) do
    case @list_toppings |> valid_permission?(@permissions, permission) do
      :ok ->
        query = from t in "toppings", select: %{id: t.id, name: t.name}
        Repo.all(query)
      {:error, response} ->
        {:error, response}
    end
  end

  def delete_topping(permission, id) do
    case @delete_topping |> valid_permission?(@permissions, permission) do
      :ok ->
        from(t in "toppings", where: t.id == ^id) |> Repo.delete_all()
      {:error, response} ->
        {:error, response}
    end
  end

  def add_toppings_to_pizza(permission, pizza_id, topping_id_list) do
    case @create_pizza |> valid_permission?(@permissions, permission) do
      :ok ->
        create_pizza_toppings({:ok, pizza_id}, topping_id_list, true)
        # TODO: Why did I comment this out? I don't think I've
        # gotten around to actually using this add_toppings_to_pizza function yet?
        # At least not in the controller, anyhow. So... that's why.
        # |> handle_add_toppings_result()
      {:error, response} ->
        {:error, response}
    end
  end

  def create_pizza_toppings({:error, message}, _), do: {:error, %{payload: %{message: message}, status: 400}}

  @doc """
    The output of create_pizza/2, which is called from within create_pizza_with_toppings/3
    is piped into this function.

    Whereas the add_toppings_to_pizza functions utilizes this function, but will never hit
    the :error function clause case.
  """
  def create_pizza_toppings({:ok, pizza_id}, topping_id_list, add_toppings_request \\ false) do
    toppings =
      topping_id_list
      |> Enum.map(fn topping_id ->
        [
          pizza_id: pizza_id,
          topping_id: topping_id,
          inserted_at: DateTime.utc_now(),
          updated_at: DateTime.utc_now()
        ]
      end)

    # TODO: What are the possible cases for this operation?
    # May need to respond with a message along the lines of
    # "Pizza was created, unfortunately your toppings fell off the table.
    #  Please refresh and try again."
    Repo.insert_all(
      "pizza_toppings",
      toppings
    )

    case add_toppings_request do
      true ->
        @toppings_added_response
      false ->
        @pizza_created_response |> update_nested([:payload], pizza_id, fn x ->
          {nil, Map.put(x, :pizza_id, pizza_id)}
        end)
    end
  end

  def retrieve_pizza_by_id(id), do: Repo.get(Pizza, id)

  def retrieve_pizza_by_name(name), do: Repo.get!(Pizza, name)

  def retrieve_pizzas, do: Repo.all(Pizza)

  def retrieve_topping_by_id(id), do: Repo.get!(Toppings, id)

  def retrieve_toppings, do: Repo.all(Toppings)


  @doc """
    The pizza's id and name will already be available on the ui
    on the pizza_list_view.

    So this function will be
    called when navigating to the pizza_detail_view.
  """
  def retrieve_pizza_toppings_by_pizzaid(pizza_id) do
    toppings =
      from(pt in "pizza_toppings",
        join: t in "toppings",
        on: pt.topping_id == t.id,
        where: pt.pizza_id == ^pizza_id,
        select: t.name
      )
      |> Repo.all()

    toppings
  end

  ##############
  ## PRIVATES ##
  ##############
  defp handle_creation_result({:ok, pizza = %Pizza{id: id, name: name}}), do: {:ok, id}
  defp handle_creation_result({:ok, topping = %Toppings{id: id, name: name}}), do: {:ok, id}

  @doc """
    errors as it appears in the changeset as the second param to this function:
    [
      name: {"That topping name is already taken",
      [validation: :unsafe_unique, fields: [:name]]}
    ]

    errors after traverse and format_errors:
    %{name: ["That topping name is already taken"]}
  """
  defp handle_creation_result({:error, changeset = %Changeset{valid?: false, errors: errors}}) do
    errors =
      changeset
      |> Changeset.traverse_errors(fn {msg, opts} ->
        # TODO: Check if :fields stays consistent as a way to check
        # that this opts data structure is representative of a unique_constraint.
        Keyword.has_key?(opts, :fields)
        |> format_error(msg, opts)
      end)

    {:error, errors}
  end

  defp update_nested(map, keys, val, func) do
    {nil, response} = map |> get_and_update_in(keys, func)
    response
  end

  # TODO: this logic (format_error) is duplicated in /accounts/lib/accounts/impl.ex
  # Perhaps move this helper error handling logic into dbstore so that
  # it may be imported here.

  # TODO: ah.... should've documented the shape of opts
  # This case handles unique_constraints
  defp format_error(true, msg, opts), do: msg

  defp format_error(false, msg, opts) do
    Enum.reduce(opts, msg, fn {key, value}, acc ->
      String.replace(acc, "%{#{key}}", to_string(value))
    end)
  end

  defp format_response({:ok, %{id: id, name: name}}, :delete_pizza) do
    {:ok, %{
      status: 200,
      payload: %{
        message: "Pizza successfully deleted!",
        deleted_pizza: %{id: id, name: name}
      }
    }}
  end

  defp format_response({_, _err}, :delete_pizza), do: "Unable to delete."

  defp format_response({:ok, id}, :create_topping) do
    # {_, payload} = @create_topping_success_response |> get_and_update_in([:payload, :topping_id], &{&1, id})
    {:ok, %{
      status: 201,
      payload: %{
        message: "Topping successfully created!",
        topping_id: id
      }
    }}
  end

  defp format_response({:error, errors}, :create_topping) do
    {:error, error_response(errors)}
  end

  defp error_response(errors) do
    %{
      status: 400,
      payload: %{
        message: errors
      }
    }
  end
end
