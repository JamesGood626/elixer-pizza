defmodule PizzaApp.Pizzas do
  alias PizzaApp.Repo
  alias PizzaApp.Pizza

  def create_pizza(name), do: Repo.insert!(%Pizza{name: name})
  def retrieve_pizza_by_id(id), do: Repo.get!(Pizza, id)
  def retrieve_pizza_by_name(name), do: Repo.get!(Pizza, name)

  def retrieve_pizzas, do: Repo.all(Pizza)

  # update
  # delete
end
