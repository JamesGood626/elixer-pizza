defmodule BackendWeb.PizzaController do
  use BackendWeb, :controller
  alias Pizzas

  def create_pizza(conn, %{"name" => name}) do
    user = Pizzas.create_pizza(name)

    %{name: name} =
      Pizzas.retrieve_pizza_by_id(user.id)
      |> Map.from_struct()
      |> IO.inspect()

    json(conn, %{message: "success", data: %{name: name}})
  end
end
