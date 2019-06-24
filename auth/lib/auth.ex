defmodule Auth do
  @moduledoc """
  Documentation for Auth.
  """

  defdelegate hash_password(password, salt), to: Auth.Impl
  defdelegate check_user_password(user, username, password), to: Auth.Impl
  defdelegate create_session_data(username, hash_key, remember_token_bytes), to: Auth.Impl
end
