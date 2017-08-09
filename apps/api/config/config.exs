use Mix.Config

config :api, ecto_repos: [Api.Repo]

import_config "#{Mix.env}.exs"
