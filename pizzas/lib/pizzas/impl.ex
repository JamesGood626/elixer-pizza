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

  # update
  # delete
end
