defmodule Dbstore.Repo.Migrations.AddPizzasTable do
  use Ecto.Migration

  def change do
    create table("pizzas") do
      add(:name, :string, null: false)
      add(:user_id, references("users"), null: false)
      timestamps()
    end

    create(unique_index("pizzas", :name))
    create(index("users", :id))
  end
end
