setup_dbstore:
				cd ../dbstore && mix deps.get && mix ecto.create \
				&& mix ecto.migrate && MIX_ENV=test mix ecto.create \
				&& MIX_ENV=test mix ecto.migrate && mix compile

setup_auth:
				cd ../auth && mix deps.get && mix clean && mix compile

setup_accounts:
				cd ../accounts && mix deps.get && mix clean  && mix compile

setup_pizzas:
				cd ../pizzas && mix deps.get && mix clean && mix compile