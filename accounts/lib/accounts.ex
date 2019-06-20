defmodule Accounts do
  @moduledoc """
  Documentation for Accounts.
  """

  defdelegate signup_user(params), to: Accounts.Impl
  defdelegate create_user(params), to: Accounts.Impl
  defdelegate retrieve_user_by_id(id), to: Accounts.Impl
  defdelegate retrieve_user_by_username(name), to: Accounts.Impl
end
