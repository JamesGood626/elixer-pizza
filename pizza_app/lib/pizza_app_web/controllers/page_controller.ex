defmodule PizzaAppWeb.PageController do
  use PizzaAppWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
