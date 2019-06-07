# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

# Configures the endpoint
config :backend, BackendWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "+pKZo3N4kOQx8qmHVOMxsCZi612iz94iQ1RlzqWLAthKm7O2yqn/kJpxhRDQLWzh",
  render_errors: [view: BackendWeb.ErrorView, accepts: ~w(html json)],
  pubsub: [name: Backend.PubSub, adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

## JUST SPENT SOOOOOO FUCKING LONG TRYING TO FIGURE OUT
# WHY THE DAMN ACCOUNTS AND PIZZAS APPS WOULDN'T START.
# Reason:
# Despite the accounts and pizzas mix projects having already been run through mix release
# and having their own app file. When the phoenix backend project is started w/ mix phx.server
# The accounts and pizzas projects' Application module's start function is executed, but their
# configuration files aren't used for connecting their Repos to their respective databases.
# YOU MUST ADD THE DATABASE CONFIGURATION INSIDE OF THE PHOENIX PROJECT'S config files.

# NOTE:
# I have yet to actually execute either Accounts.Repo or Pizzas.Repo from the phoenix server instance.
# That will be the next step to determine whether this is truly the solution.

# IMPROVEMENTS:
# Since there will only be one database necessary. It is superfluous to include Ecto in both the Accounts and Pizzas
# projects. Create a third mix project to serve as a dependency for Accounts and Pizzas.
# COROLLARY -> With this change, then the new project will be a mix dependency of the Accounts and Pizzas projects; therefore,
# You may keep their configuration files as is, because it will conform to the explanation of REASON above.

# RUNNING ONE LAST TEST BEFORE I CONFIRM MY SUSPICIONS (**):
# So when adding the Dbstore (The project which contains the Ecto Repo)
# I assumed that putting the db connection info in the config files of the projects that directly import
# the Dbstore project into their mixfile would be satisfactory for establishing db connection upon mix phx.server start.

# However, it seems as though irregardless of the Dbstore being a direct dependency of the accounts project, that the
# db config info still needs to be inside of the top level phoenix project in order to establish db connection.

# (**) CONFIRMED, THIS IS THE BEHAVIOR.
# this is the error message (so you may include it in blog post)
# ** (RuntimeError) connect raised KeyError exception: key :database not found.
# The exception details are hidden, as they may contain sensitive data such as database
# credentials. You may set :show_sensitive_data_on_connection_error to true when starting
# your connection if you wish to see all of the details

config :dbstore, ecto_repos: [Dbstore.Repo]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
