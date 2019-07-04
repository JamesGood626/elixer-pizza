defmodule Pizzas.Impl do
  @moduledoc """
  Documentation for Pizzas.Impl.
  """
  import Ecto.Query
  alias Ecto.Changeset
  alias Dbstore.Repo
  alias Dbstore.{Pizza, Toppings, PizzaTopping}

  def create_pizza_with_toppings({:error, failure_response}, _, _), do: failure_response

  def create_pizza_with_toppings(user_id, pizza_name, topping_id_list) do
    IO.puts("result of creating a pizza")
    Impl.create_pizza(user_id, pizza_name) |> IO.inspect()

    %{
      payload: %{message: "I think the pizza resource was created successfully."},
      status: 201
    }
  end

  def create_pizza(user_id, pizza_name) do
    %Pizza{}
    |> Pizza.changeset(%{name: pizza_name, user_id: user_id})
    |> Repo.insert()

    # |> handle_create_pizza_result()
  end

  def create_pizza_toppings(pizza_id, topping_id_list) do
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
    Repo.insert_all(
      "pizza_toppings",
      toppings
    )

    %{
      payload: %{message: "I think the pizza toppings resource was created successfully."},
      status: 201
    }
  end

  def retrieve_pizza_by_id(id), do: Repo.get!(Pizza, id)

  def retrieve_pizza_by_name(name), do: Repo.get!(Pizza, name)

  def retrieve_pizzas, do: Repo.all(Pizza)

  def retrieve_toppings, do: Repo.all(Toppings)

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

  defp handle_create_pizza_result({:ok, pizza = %Pizza{id: id, name: name}}) do
    {:ok, %{id: id, name: name}}
  end

  defp handle_create_pizza_result({:error, changeset = %Changeset{valid?: false, errors: errors}}) do
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

  # This case handles unique_constraints
  defp format_error(true, msg, opts), do: msg

  defp format_error(false, msg, opts) do
    Enum.reduce(opts, msg, fn {key, value}, acc ->
      String.replace(acc, "%{#{key}}", to_string(value))
    end)
  end
end
