bootstrap_dbstore:
				cd ../dbstore && mix deps.get && mix ecto.create \
				&& mix ecto.migrate && MIX_ENV=test mix ecto.create \
				&& MIX_ENV=test mix ecto.migrate && mix compile

bootstrap_auth:
				cd ../auth && mix deps.get && mix clean && mix compile

bootstrap_accounts:
				cd ../accounts && mix deps.get && mix clean && mix compile

bootstrap_pizzas:
				cd ../pizzas && mix deps.get && mix clean && mix compile

recompile_dbstore:
				cd ../dbstore && mix clean && mix compile

recompile_auth:
				cd ../auth && mix clean && mix compile

recompile_accounts:
				cd ../accounts && mix clean && mix compile

recompile_pizzas:
				cd ../pizzas && mix clean && mix compile