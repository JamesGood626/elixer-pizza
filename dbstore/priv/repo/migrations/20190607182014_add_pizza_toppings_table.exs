defmodule Dbstore.Repo.Migrations.AddPizzaToppingsTable do
  use Ecto.Migration

  def change do
    create table("pizza_toppings") do
      add(:pizza_id, references(:pizzas), on_delete: :delete_all, null: false)
      add(:topping_id, references(:toppings), on_delete: :delete_all,  null: false)
      timestamps()
    end

    create(index("pizza_toppings", :pizza_id))
    create(index("pizza_toppings", :topping_id))
  end
end
