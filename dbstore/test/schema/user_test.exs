defmodule UserTest do
  use ExUnit.Case
  alias Ecto.Changeset
  alias Dbstore.User

  @user_struct %User{}
  @valid_input %{username: "user_one", password: "user_one_password"}
  @invalid_input %{username: "da", password: "da_password"}

  @username_length_errors [
    username:
      {"should be at least %{count} character(s)",
       [count: 3, validation: :length, kind: :min, type: :string]}
  ]

  describe "user changeset generates" do
    test "valid changeset w/ user's input password hashed" do
      assert %Changeset{
               valid?: true,
               changes: %{
                 username: "user_one",
                 password: "user_one_password",
                 password_hash: password_hash
               },
               errors: []
             } = User.changeset(@user_struct, @valid_input)

      assert String.codepoints(password_hash) |> length === 98
    end

    test "invalid changeset w/ unacceptable username length input." do
      assert %Changeset{
               valid?: false,
               changes: @invalid_input,
               errors: @username_length_errors
             } = User.changeset(@user_struct, @invalid_input)
    end
  end
end
