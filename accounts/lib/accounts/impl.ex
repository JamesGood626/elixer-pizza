defmodule Accounts.Impl do
  @moduledoc """
  Documentation for Accounts.Impl
  """
  import Ecto.Query
  alias Ecto.Changeset
  alias Dbstore.{Repo, User, Permissions}

  # Key for hashing the user's remember_token TODO: (This is duplicated in backend/temp/auth_plug.ex)
  # mix phx.gen.secret [length]
  # TODO: keep this secret in prod
  # WARNING: This is duplicated in the backend project's auth_plug.ex file
  @hash_key "7b8lEvA2aWxGB1f2MhBjhz8YRf1p21fgTxn8Qf6KciM9IJCaJ9aIn4SNna0FybxZ"
  @remember_token_bytes 32

  # User Permissions
  @pizza_application_maker "PIZZA_APPLICATION_MAKER"
  @pizza_operations_manager "PIZZA_OPERATION_MANAGER"
  @pizza_chef "PIZZA_CHEF"

  # Status Codes
  @created_code 201
  @bad_request_code 400
  @forbidden_code 403

  # Response Messages
  @signup_success_message "You've successfully signed up!"
  @login_success_message "You've successfully logged in!"
  @something_went_wrong_message "Oops... Something went wrong. Please try again."
  @permission_not_found_message "Permission not found"

  # Introduced this to provide "PIZZA_APPLICATION_MNAKER" to tests
  # And I suppose this is how any admins introduced into the prod version
  # will be created... But I still wanted to do more research to determine
  # if this is really the best way to go about it.
  def signup_pizza_app_maker(params) do
    params
    |> create_user_with_permission(@pizza_application_maker)
    |> Repo.transaction()
    |> login_user()
    |> format_response(@signup_success_message)
  end

  def signup_pizza_ops_manager(params) do
    params
    |> create_user_with_permission(@pizza_operations_manager)
    |> Repo.transaction()
    |> login_user()
    |> format_response(@signup_success_message)
  end

  def signup_pizza_chef(params) do
    params
    |> create_user_with_permission(@pizza_chef)
    |> Repo.transaction()
    |> login_user()
    |> format_response(@signup_success_message)
  end

  def login(%{username: username, password: password}) do
    retrieve_user_by_username(username)
    |> Auth.check_password(password)
    |> login_user()
    |> format_response(@login_success_message)
  end

  def retrieve_user_by_id(id), do: Repo.get!(User, id)

  # Repo.get_by either returns the resource Struct or nil
  def retrieve_user_by_username(username), do: Repo.get_by(User, username: username)

  def retrieve_user_with_permission(username) do
    [user_permission_result | []] =
      from(u in "users",
        join: up in "user_permissions",
        on: u.id == up.user_id,
        join: p in "permissions",
        on: up.permission_id == p.id,
        where: u.username == ^username,
        select: {u.id, p.name}
      )
      |> Repo.all()

    user_permission_result
  end

  def retrieve_permission_by_name(name), do: Repo.get_by(Permissions, name: name)

  @doc """
    Users are anticipated to only have one permission for the lifetime of their account.
  """
  def retrieve_user_permissions_by_userid(user_id) do
    [permission | _] =
      from(up in "user_permissions",
        join: p in "permissions",
        on: up.permission_id == p.id,
        where: up.user_id == ^user_id,
        select: p.name
      )
      |> Repo.all()

    permission
  end

  ##################
  #### PRIVATES ####
  ##################

  defp create_user_with_permission(params, permission) do
    fn ->
      create_user(params)
      |> setup_user_permissions(permission)
    end
  end

  @doc """
    Creates a user when provided with valid input:

    create_user(%{username: "user_one", password: "password"})
    {:ok, %{id: 1, username: "user_one"}}

    Returns an error tuple when provided with invalid input:

    create_user(%{username: "da", password: "password"})
    {:error, errors: %{username: ["should be at least 3 character(s)"]}}
  """
  defp create_user(params) do
    %User{}
    |> User.changeset(params)
    |> Repo.insert()
    |> handle_create_user_result
  end

  defp setup_user_permissions({:ok, %{id: user_id, username: username}}, permission) do
    retrieve_permission_by_name(permission)
    |> got_permission?()
    |> handle_create_user_permission(user_id, username)
  end

  @doc """
    setup_user_permissions({:error, errors}, @pizza_chef)

    A status code and errors array will be returned from this function,
    and be used inside of signup_user_response send back as a response
    to the client.
  """
  defp setup_user_permissions({:error, errors}, _permission) do
    Repo.rollback(%{status: @bad_request_code, errors: errors})
  end

  defp got_permission?(%Permissions{id: permission_id}), do: permission_id
  defp got_permission?(nil), do: Repo.rollback(@permission_not_found_message)

  defp handle_create_user_permission(permission_id, user_id, username)
       when is_integer(permission_id) do
    case create_user_permission(user_id, permission_id) do
      {1, nil} ->
        # Successfully signed up
        %{user_id: user_id, username: username}

      _ ->
        Repo.rollback(@something_went_wrong_message)
    end
  end

  @doc """
    Have this here just in case Repo.rollback is called in got_permission?/1.
    It doesn't return a value, but I'm not sure if it immediately returns from the function.
    and will immediately terminate the execution of setup_user_permissions and not call this function.
    My assumption is that is what it does... but I'll need to play w/ it.
  """
  defp handle_create_user_permission(_permission_id, _user_id, _username),
    do: Repo.rollback(@something_went_wrong_message)

  defp create_user_permission(user_id, permission_id) do
    Repo.insert_all("user_permissions", [
      [
        user_id: user_id,
        permission_id: permission_id,
        inserted_at: DateTime.utc_now(),
        updated_at: DateTime.utc_now()
      ]
    ])
  end

  defp login_user({:ok, %{user_id: user_id, username: username}}) do
    case Auth.create_session_data(username, @hash_key, @remember_token_bytes) do
      {:ok, {session_data, hashed_remember_token}} ->
        update_user_hashed_remember_token(user_id, hashed_remember_token)
        # Retrieving this permission is more of a quick fix...
        # Should just pass in the permission from the respective signup functions.
        # And then the login function should retrieve_user_with_permission to avoid
        # reaching out to the DB four times.
        permission = retrieve_user_permissions_by_userid(user_id)
        {:ok, %{username: username, permission: permission}, session_data}

      {:error, _msg} ->
        # TODO: Need to check the form of the other errors, and ensure that
        # this arbitrary error message matches the same shape.
        {:error, %{status: @bad_request_code, errors: @something_went_wrong_message}}
    end
  end

  defp login_user({:error, response}), do: {:error, response}

  defp format_response({:ok, %{username: username, permission: permission}, session_data}, message) do
    %{
      status: @created_code,
      payload: %{message: message, username: username, permission: permission},
      session_data: session_data
    }
  end

  # TODO: Revisit this after putting more consideration into how I'll make my Auth module
  # more flexible for future reuse.
  # NOTE: This is necessary because when the Auth.check_user_password case fails ->
  # It returns {:error, "Username or password is incorrect"} And that caused a runtime
  # exception when I was running tests. So I've added this function clause temporarily.
  defp format_response({:error, msg}, _message) do
    %{status: 400, payload: %{errors: msg}, session_data: nil}
  end

  defp format_response({:error, %{status: status, errors: errors}}, _message) do
    %{status: status, payload: %{errors: errors}, session_data: nil}
  end

  defp handle_create_user_result({:ok, user = %User{id: id, username: username}}) do
    {:ok, %{id: id, username: username}}
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
        # TODO: Check if :fields stays consistent as a way to check
        # that this opts data structure is representative of a unique_constraint.
        Keyword.has_key?(opts, :fields)
        |> format_error(msg, opts)
      end)

    {:error, errors}
  end

  # This case handles unique_constraints
  defp format_error(true, msg, opts), do: msg

  defp format_error(false, msg, opts) do
    Enum.reduce(opts, msg, fn {key, value}, acc ->
      String.replace(acc, "%{#{key}}", to_string(value))
    end)
  end

  defp update_user_hashed_remember_token(user_id, hashed_remember_token) do
    %User{id: user_id}
    |> Ecto.Changeset.cast(
      %{hashed_remember_token: hashed_remember_token},
      [:hashed_remember_token]
    )
    |> Repo.update()
  end
end
