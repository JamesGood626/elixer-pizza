defmodule BackendWeb.Router do
  use BackendWeb, :router

  pipeline :api do
    plug(:accepts, ["json"])
    plug(:fetch_session)
    # plug(:protect_from_forgery)
    plug(:put_secure_browser_headers)
  end

  scope "/api", BackendWeb do
    pipe_through(:api)

    # UserControllers
    get("/csrf", UserController, :csrf)
    post("/signup_pizza_ops_manager", UserController, :signup_pizza_ops_manager)
    post("/signup_pizza_chef", UserController, :signup_pizza_chef)
    post("/login", UserController, :login)
    post("/logout", UserController, :logout)

    # PizzaControllers
    post("/pizza", PizzaController, :create_pizza)
    # get("/pizza", PizzaController, :list_pizza)
    delete("/pizza/:id", PizzaController, :delete_pizza)
    post("/pizza/toppings", PizzaController, :add_toppings)
    get("/toppings", ToppingController, :list_toppings)
    post("/toppings", ToppingController, :create_topping)
    post("/toppings/delete", ToppingController, :delete_topping)
  end
end
