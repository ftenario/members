# Members

## Description
This is an eample application using Ecto and Mysql. These are the steps on how to setup
Ecto, its dependencies and create database and tables.

## Installation

## 1. To create this project:
$ mix new members --sup

## 2. Open up mix.exs in an editor and add

```
def deps do
  [
      {:ecto, "~> 2.0"},
      {:mariaex, ">= 0.8.2"},
  ]
end
```

## 3. Setup some configuration for Ecto to be able to talk to Mysql database
```
$ mix ecto.gen.repo -r Members.Repo
```

## 4. Configure in config/config.exs

```
config :members, Members.Repo,
  adapter: Ecto.Adapters.Mysql,
  database: "members_repo",
  username: "user",
  password: "pasword",
  hostname: "localhost"
```

## 5. Members.Repo module is defined in lib/members/repo.ex

```
defmodule Members.Repo do
  use Ecto.Repo, otp_app: :members
end
```

## 6. Setup Members.Repo as a supervisor within the application's supervisor tree. In /lib/members/applicaiton.ex

```
def start(_type, _args) do
    import Supervisor.Spec

    children = [
      Friends.Repo
    ]
  end
```
This is needed for the Ecto process be able to query the database

## 7. Add another configguration to config/config.exs

```
  config :members, ecto_repos: [Members.Repo]
```

## 8. Setting up the Database

```
$ mix ecto.create
```
At this time, the database has been created. You cannot query the database yet, since there aren't any tables.

## 9. Lets create a migration to create a table.

```
$ mix ecto.gen.migration create_members
```

