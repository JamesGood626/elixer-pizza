defmodule PizzaApp.Repo.Migrations.AddUserPermissionsTable do
  use Ecto.Migration

  def change do
    create table("user_permissions") do
      add :user_id, references("users"), null: false
      add :permission_id, references("permissions"), null: false
      timestamps()
    end

    create index("user_permissions", :user_id)
    create index("user_permissions", :permission_id)
  end
end
