defmodule BackendWeb.Router do
  use BackendWeb, :router

  pipeline :browser do
    plug(:accepts, ["html"])
    plug(:fetch_session)
    plug(:fetch_flash)
    # plug(:protect_from_forgery)
    plug(:put_secure_browser_headers)
  end

  pipeline :api do
    plug(:accepts, ["json"])
    plug(:fetch_session)
  end

  scope "/", BackendWeb do
    pipe_through(:browser)
  end

  # Other scopes may use custom stacks.
  scope "/api", BackendWeb do
    pipe_through(:api)

    # UserControllers
    post("/signup_pizza_ops_manager", UserController, :signup_pizza_ops_manager)
    post("/signup_pizza_chef", UserController, :signup_pizza_chef)

    # PizzaControllers
    post("/pizza", PizzaController, :create_pizza)
  end
end
