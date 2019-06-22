defmodule Dbstore.Repo.Migrations.AddPermissionsTable do
  use Ecto.Migration

  def change do
    create table("permissions") do
      add(:name, :string, null: false)
      timestamps()
    end

    create(unique_index("permissions", :name))
  end
end
