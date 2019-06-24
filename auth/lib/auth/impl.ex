defmodule Auth.Impl do
  use Timex

  def hash_password(password, salt) do
    Argon2.Base.hash_password(password, salt, t_cost: 4, m_cost: 18)
  end

  def check_user_password(user, password) do
    # Can only assume this returns -> true or false
    user |> Argon2.check_pass(password)
  end

  def create_session_data(username, hash_key, bytes) do
    generate_remember_token(bytes)
    |> hash_remember_token(hash_key)
    |> generate_session_data(username)
  end

  defp generate_remember_token(remember_token_bytes) do
    :crypto.strong_rand_bytes(remember_token_bytes) |> Base.encode64()
  end

  defp hash_remember_token(remember_token, hash_key) do
    case :crypto.hmac(:sha256, hash_key, remember_token) |> Base.encode64() do
      hashed_remember_token ->
        {:ok, {remember_token, hashed_remember_token}}

      _ ->
        {:error, "Something went wrong hashing the remember_token"}
    end
  end

  defp generate_session_data({:ok, {remember_token, hashed_remember_token}}, username) do
    session_data =
      %{username: username, remember_token: remember_token}
      |> generate_expiry_time

    {:ok, {session_data, hashed_remember_token}}
  end

  # Handling the failure case of hash_remember_token/2
  defp generate_session_data({:error, msg}), do: {:error, msg}

  defp generate_expiry_time(session_data) do
    expiry =
      Timex.now()
      |> Timex.shift(days: 1, hours: 12)
      |> DateTime.to_unix()

    Map.put(session_data, :expiry, expiry)
  end
end
