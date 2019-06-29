defmodule Backend.AuthPlug do
  import Plug.Conn
  alias Accounts
  alias Auth

  # Key for hashing the user's remember_token TODO: (This is duplicated in lib/accounts/impl.ex)
  @hash_key "Ahsdujadsnkjadnskja"

  def authorize_user(conn, _opts) do
    get_session(conn, :session_token) |> authorize(conn)
  end

  defp authorize(nil, conn), do: assign(conn, :current_user, nil)

  defp authorize(%{expiry: expiry} = params, conn) do
    Timex.now()
    |> DateTime.to_unix()
    |> check_expiry(expiry)
    |> fetch_user(params)
    |> auth_check()
    |> assign_user_to_conn(conn)
  end

  defp check_expiry(datetime, expiry) do
    case datetime < expiry do
      true ->
        {:ok, "Valid session"}

      false ->
        {:error, "Invaid session"}
    end
  end

  defp fetch_user({:ok, "Valid session"}, %{username: username, remember_token: remember_token}) do
    case Accounts.retrieve_user_by_username(username) do
      user ->
        {:ok, {user, remember_token}}

      nil ->
        {:error, "Session cleared due to being unable to find user by username."}
    end
  end

  defp fetch_user({:error, msg}, _params), do: {:error, msg}

  defp auth_check({:ok, {user, remember_token}}) do
    case remember_token_matches?(user, remember_token) do
      true ->
        {:ok, user}

      false ->
        {:error, "Remember token doesn't match hashed remember token"}
    end
  end

  defp auth_check({:error, msg}), do: {:error, msg}

  defp assign_user_to_conn({:ok, user}, conn), do: conn |> set_session(user)
  defp assign_user_to_conn({:error, _msg}, conn), do: conn |> clean_session()

  @doc """
    remember_token is the incoming token from the request.

    hashed_remember_token is the one that was stored in Credential
    GenServer state.

    TODO: add user struct pattern match for the first arg for extra clarity
  """
  defp remember_token_matches?(
         %{hashed_remember_token: hashed_remember_token},
         remember_token
       ) do
    {:ok, {_remember_token, hashed_token}} = Auth.hash_remember_token(remember_token, @hash_key)
    hashed_token === hashed_remember_token
  end

  defp set_session(conn, user), do: conn |> assign(:current_user, user.username)

  defp clean_session(conn),
    do: conn |> delete_session(:session_token) |> assign(:current_user, nil)
end
