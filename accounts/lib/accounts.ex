defmodule Accounts do
  @moduledoc """
  Documentation for Accounts.
  """

  defdelegate signup_pizza_app_maker(params), to: Accounts.Impl
  defdelegate signup_pizza_ops_manager(params), to: Accounts.Impl
  defdelegate signup_pizza_chef(params), to: Accounts.Impl
  defdelegate login(params), to: Accounts.Impl
  defdelegate retrieve_user_by_id(id), to: Accounts.Impl
  defdelegate retrieve_user_by_username(username), to: Accounts.Impl
  defdelegate retrieve_user_with_permission(username), to: Accounts.Impl
  defdelegate retrieve_user_permissions_by_userid(user_id), to: Accounts.Impl
end
