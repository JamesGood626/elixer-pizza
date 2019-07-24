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

  # TODO:
  # Implement in toppings_controller
  # "PIZZA_OPERATION_MANAGER" should be able to:
  # - see a list of available toppings
  # - allowed to add a new topping <- CHECK
  # - allowed to delete an existing topping


  # TODO: More than likely going to need to revisit this implementation of
  # checking permissions if more than two permissions may perform the same action.
  # UPDATE:
  # Yes, after re-reading the spec


  # "PIZZA_CHEF"
  # - allowed to see a list of existing pizzas and their toppings
  # - allowed to create a new pizza and add toppings to it
  # - allowed to delete an existing pizza
  # "PIZZA_APPLICATION_MAKER"
  # Is only listed for the backend stories, but I assume this requires an admin
  # interface, so the permissions map will need to look as such:
  # %{ "LIST_PIZZAS" => ["PIZZA_APPLICATION_MAKER", "PIZZA_CHEF"] }
  # And that will require iterating over the map inside of valid_permission?
  @permissions %{
    @create_pizza => [@pizza_application_maker, @pizza_chef],
    @add_toppings => [@pizza_application_maker, @pizza_chef],
    @list_pizzas => [@pizza_application_maker, @pizza_chef],
    @delete_pizza => [@pizza_application_maker, @pizza_chef],
    @create_topping => [@pizza_application_maker, @pizza_operation_manager]
  }

  # TODO: This needs to be incorporated into the auth lib
  #       and then passed into whatever functions require
  #       authorization, along with the roles/permissions.
  defp valid_permission?(action, permissions, permission) do
    permissions
    |> Map.get(action, permission)
    |> Enum.any?(fn x -> x == permission end)
    |> case do
      true ->
        :ok
      false ->
        {:error, %{payload: %{message: "You're unable to perform that action."}, status: 400}}
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

  def create_topping(permission, name) do
    # TODO: Repition going on. Should use an anon func to pass in the action & :ok logic
    # And move the general case stuff out into a separate function.
    case @create_topping |> valid_permission?(@permissions, permission) do
      :ok ->
        %Toppings{}
          |> Toppings.changeset(%{name: name})
          |> Repo.insert()
          |> handle_creation_result()
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
        @pizza_created_response
    end
  end

  def retrieve_pizza_by_id(id), do: Repo.get!(Pizza, id)

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
end
