defmodule Dbstore.Repo.Migrations.AddToppingsTable do
  use Ecto.Migration

  def change do
    create table("toppings") do
      add(:name, :string, null: false)
      timestamps()
    end

    create(unique_index("toppings", :name))
  end
end
