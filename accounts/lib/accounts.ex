defmodule Accounts do
  @moduledoc """
  Documentation for Accounts.
  """

  defdelegate signup_pizza_ops_manager(params), to: Accounts.Impl
  defdelegate signup_pizza_chef(params), to: Accounts.Impl
  defdelegate retrieve_user_by_id(id), to: Accounts.Impl
  defdelegate retrieve_user_by_username(name), to: Accounts.Impl
end
