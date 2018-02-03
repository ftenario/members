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
  password: "password",
  hostname: "localhost"

 This is assumed that you already installed Mysql database server and configured to have a suername and password. 
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

$mysql -u <username> -p 
mysql> use members_repo;
Database changed
mysql> show tables;
Empty set (0.01 sec)

```
At this time, the database has been created. You cannot query the database yet, since there aren't any tables.

## 9. Lets create a migration to create a table.

```
$ mix ecto.gen.migration create_members
```

This will create a migration file which can be found in priv/repo/migrations

```
* creating priv/repo/migrations
* creating priv/repo/migrations/20180203173916_create_member.exs
```

## 10. Add columns to the migration file.

Open the *_create_members.exs file and add the following:

```
defmodule Members.Repo.Migrations.CreateMember do
  use Ecto.Migration

  def change do
    create_table(:member) do
      add :member_id, :string
      add :first_name, :string
      add :last_name, :string
      add :birthdate, :date
      add :gender, :string 

      timestamps()
    end
  end
end
``` 

## 10. Run the migration file

This will create the table 'member'

```
$ mix ecto.migrate


mysql> desc member;
+-------------+---------------------+------+-----+---------+----------------+
| Field       | Type                | Null | Key | Default | Extra          |
+-------------+---------------------+------+-----+---------+----------------+
| id          | bigint(20) unsigned | NO   | PRI | NULL    | auto_increment |
| member_id   | varchar(255)        | YES  |     | NULL    |                |
| first_name  | varchar(255)        | YES  |     | NULL    |                |
| last_name   | varchar(255)        | YES  |     | NULL    |                |
| birthdate   | date                | YES  |     | NULL    |                |
| gender      | varchar(255)        | YES  |     | NULL    |                |
| inserted_at | datetime            | NO   |     | NULL    |                |
| updated_at  | datetime            | NO   |     | NULL    |                |
+-------------+---------------------+------+-----+---------+----------------+
8 rows in set (0.00 sec)
```

You can do a rollback if you made a mistake in your script and run 'mix ecto.migrate' again

```
$ mix ecto.rollback
```

## 11. Creating the Schema

