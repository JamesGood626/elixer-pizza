defmodule Accounts do
  @moduledoc """
  Documentation for Accounts.
  """

  defdelegate create_user(username), to: Accounts.Impl
  defdelegate retrieve_user_by_id(id), to: Accounts.Impl
  defdelegate retrieve_user_by_username(name), to: Accounts.Impl
end
