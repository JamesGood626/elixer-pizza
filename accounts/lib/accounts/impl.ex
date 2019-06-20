defmodule Accounts.Impl do
  @moduledoc """
  Documentation for Accounts.Impl
  """
  alias Ecto.Changeset
  alias Dbstore.Repo
  alias Dbstore.User

  @username_length_error %{
    field: "username",
    message: "Username must be between 3 and 20 characters in length"
  }
  @password_length_error %{
    field: "password",
    message: "Password must be between 8 and 50 characters in length"
  }
  @oops_error %{
    field: "_",
    message: "Oops.. Something went wrong"
  }

  def signup_user(params) do
    create_user(params)
    |> handle_create_user_result
  end

  # TODO: This is really private too... but I need to figure out how to
  # make it private and still allow it to be tested. (Like the tests for documentation)
  def create_user(params) do
    %User{}
    |> User.changeset(params)
    |> Repo.insert()
  end

  def retrieve_user_by_id(id), do: Repo.get!(User, id)

  def retrieve_user_by_username(username), do: Repo.get!(User, username)

  ##################
  #### PRIVATES ####
  ##################
  defp handle_create_user_result({:ok, user = %User{username: username}}) do
    # TODO: authenticate user and set session.
    %{status: 200, payload: %{message: "You've successfully signed up!", username: username}}
  end

  @doc """
    Ecto.Changeset.traverse_errors/2

    Transforms:
    {"should be at least %{count} character(s)", [count: 8, validation: :length, kind: :min, type: :string]}

    Into:
    "password": ["should be at least 8 character(s)"]

    Small downside, is that it traverses over all of the opts in {_msg, opts}, when you only need the count from
    the opts keyword list.

    Except in the case of a unique_constraint message being displayed.
    Then we just return the message as there is no variable to replace in the string.
  """
  defp handle_create_user_result({:error, changeset = %Changeset{valid?: false, errors: errors}}) do
    errors =
      changeset
      |> Changeset.traverse_errors(fn {msg, opts} ->
        Keyword.has_key?(opts, :validation)
        |> format_error(msg, opts)
      end)

    %{status: 202, payload: %{errors: errors}}
  end

  # This case handles unique_constraints
  defp format_error(true, msg, opts), do: msg

  defp format_error(false, msg, opts) do
    Enum.reduce(opts, msg, fn {key, value}, acc ->
      String.replace(acc, "%{#{key}}", to_string(value))
    end)
  end
end
