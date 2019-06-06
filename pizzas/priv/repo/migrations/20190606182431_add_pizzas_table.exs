defmodule Pizzas.Repo.Migrations.AddPizzasTable do
  use Ecto.Migration

  def change do
    create table("pizzas") do
      add(:name, :string, null: false)
      timestamps()
    end

    create(unique_index("pizzas", :name))
  end
end
