defmodule Pizzas.Impl do
  @moduledoc """
  Documentation for Pizzas.Impl.
  """

  @doc """
  Hello world.

  ## Examples

      iex> Pizzas.hello()
      :world

  """
  def hello do
    :world
  end

  alias Dbstore.Repo
  alias Dbstore.Pizza

  def create_pizza(name), do: Repo.insert!(%Pizza{name: name})

  def retrieve_pizza_by_id(id), do: Repo.get!(Pizza, id)

  def retrieve_pizza_by_name(name), do: Repo.get!(Pizza, name)

  def retrieve_pizzas, do: Repo.all(Pizza)

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

  defp create_pizza_toppings(pizza_id, topping_id_list) do
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

    Repo.insert_all(
      "pizza_toppings",
      toppings
    )
  end
end
