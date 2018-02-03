# Members

**TODO: Add description**

## Installation

# To create this project:
$ mix new members --sup

# Open up mix.exs in an editor and add

```
def deps do
  [
      {:ecto, "~> 2.0"},
      {:mariaex, ">= 0.8.2"},
  ]
end
```

# Setup some configuration for Ecto to be able to talk to Mysql database
$ mix ecto.gen.repo -r Members.Repo

# Configure in config/config.exs

```
config :members, Members.Repo,
  adapter: Ecto.Adapters.Mysql,
  database: "members_repo",
  username: "user",
  password: "pasword",
  hostname: "localhost"
```

# Members.Repo module is defined in lib/members/repo.ex
```
defmodule Members.Repo do
  use Ecto.Repo, otp_app: :members
end
```

# Setup Members.Repo as a supervisor within the application's supervisor tree. In /lib/members/applicaiton.ex

```
def start(_type, _args) do
    import Supervisor.Spec

    children = [
      Friends.Repo
    ]
  end
```
This is needed for the Ecto process be able to query the database

# Add another configguration to config/config.exs

```
  config :members, ecto_repos: [Members.Repo]
```

# Setting up the Database

