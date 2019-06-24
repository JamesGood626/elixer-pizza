defmodule Dbstore.Repo.Migrations.AddUsersTable do
  use Ecto.Migration

  def change do
    create table("users") do
      add(:username, :string, null: false)
      add(:hashed_remember_token, :string)
      add(:password_hash, :string, null: false)
      timestamps()
    end

    create(unique_index("users", :username))
  end
end
