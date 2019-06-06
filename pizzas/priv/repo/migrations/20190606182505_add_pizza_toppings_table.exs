defmodule Pizzas.Repo.Migrations.AddPizzaToppingsTable do
  use Ecto.Migration

  def change do
    create table("pizza_toppings") do
      add(:pizza_id, references("pizzas"), null: false)
      add(:topping_id, references("toppings"), null: false)
      timestamps()
    end

    create(index("pizza_toppings", :pizza_id))
    create(index("pizza_toppings", :topping_id))
  end
end
