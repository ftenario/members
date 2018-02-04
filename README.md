# Members

## Description
An example using Ecto and Mysql. These are the steps on how to setup
Ecto, its dependencies and create database and tables in MySQL.

## Installation

## 1. To create this project:
$ mix new members --sup

## 2. Open up mix.exs in an editor and add

```
def deps do
  [
      {:ecto, "~> 2.0"},
      {:mariaex, ">= 0.8.2"},
      {:timex, "~> 3.0"},
      {:timex_ecto, "~> 3.0"},
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

 This is assumed that you already installed Mysql database server and configured to 
 have a username and password. 
```

## 5. Members.Repo module is defined in lib/members/repo.ex

```
defmodule Members.Repo do
  use Ecto.Repo, otp_app: :members
end
```

## 6. Setup Members.Repo as a supervisor within the application's supervisor tree. In /lib/members/application.ex

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
At this time, the database has been created. You cannot query the database yet, 
since there aren't any tables.

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
      add :birthdate, Timex.Ecto.Date
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

By creating a schema, we associate the database table to Elixir. It is a representation on Elixir of the data from the database.

Create a file "lib/members/member.ex". The schema "member" is a singular naming convention.

```
defmodule Members.Member do
    use Ecto.Schema

    schema "member" do
        field :member_id, :string
        field :first_name, :string
        field :last_name, :string
        field :birthdate, Timex.Ecto.Date  
        field :gender, :string
        timestamps
    end
end
``` 

Then you can play around iex by running 'iex -S mix'. This creates a blank member
```
iex(1)> person = %Members.Member{}
%Members.Member{__meta__: #Ecto.Schema.Metadata<:built, "member">,
 birthdate: nil, first_name: nil, gender: nil, id: nil, inserted_at: nil,
 last_name: nil, member_id: nil, updated_at: nil}
iex(2)>
```

Create a new Member with data

```
iex(7)> person = %Members.Member{member_id: "1234", first_name: "John", last_name: "Doe", birthdate: {2000,01,01}, gender: "M"}
%Members.Member{__meta__: #Ecto.Schema.Metadata<:built, "member">,
 birthdate: {2000, 1, 1}, first_name: "John", gender: "M", id: nil,
 inserted_at: nil, last_name: "Doe", member_id: "1234", updated_at: nil}
iex(8)>
```
## 12. Insert Data

```
iex(2)> Members.Repo.insert(person)
12:25:41.836 [debug] QUERY OK db=6.2ms
INSERT INTO `member` (`birthdate`,`first_name`,`gender`,`last_name`,`member_id`,`inserted_at`,`updated_at`) VALUES (?,?,?,?,?,?,?) [{2000, 1, 1}, "John", "M", "Doe", "1234", {{2018, 2, 3}, {20, 25, 41, 821334}}, {{2018, 2, 3}, {20, 25, 41, 822841}}]
{:ok,
 %Members.Member{__meta__: #Ecto.Schema.Metadata<:loaded, "member">,
  birthdate: {2000, 1, 1}, first_name: "John", gender: "M", id: 3,
  inserted_at: ~N[2018-02-03 20:25:41.821334], last_name: "Doe",
  member_id: "1234", updated_at: ~N[2018-02-03 20:25:41.822841]}}
iex(3)>
```

## 13. Validating Changes
You can validate changes before the data is actually save to the database. For example, member_id, first_name and last_name is required.

Add a changeset to Members.Member module in /lib/members/member.ex

```
def changeset(member, params \\ %{}) do
  member
  |> Ecto.Changeset.cast(params, [:member_id, :first_name, :last_name, :birthdate, :gender])
  |> Ecto.Changeset.validate_required([:member_id, :first_name, :last_name])
end  
```
The cast changeset tells Ecto which parameters are allowed. The second one, tells which parameters are required.

Lets check how changeset is use:

```
iex(12)> person = %Members.Member{}
%Members.Member{__meta__: #Ecto.Schema.Metadata<:built, "member">,
 birthdate: nil, first_name: nil, gender: nil, id: nil, inserted_at: nil,
 last_name: nil, member_id: nil, updated_at: nil}
iex(13)>
nil
iex(14)> changeset = Members.Member.changeset(person)
#Ecto.Changeset<action: nil, changes: %{},
 errors: [member_id: {"can't be blank", [validation: :required]},
  first_name: {"can't be blank", [validation: :required]},
  last_name: {"can't be blank", [validation: :required]}],
 data: #Members.Member<>, valid?: false>
```

You can also check the changeset first before doing an insert:

```
iex(16)> changeset.valid?
false
iex(17)>
```

Lets do a changeset with valid data:

```
iex(17)> person = %Members.Member{member_id: "9807", first_name: "Jane", last_name: "Doe"}
%Members.Member{__meta__: #Ecto.Schema.Metadata<:built, "member">,
 birthdate: nil, first_name: "Jane", gender: nil, id: nil, inserted_at: nil,
 last_name: "Doe", member_id: "9807", updated_at: nil}
iex(18)>
nil
iex(19)> changeset = Members.Member.changeset(person)
#Ecto.Changeset<action: nil, changes: %{}, errors: [], data: #Members.Member<>,
 valid?: true>
iex(20)> changeset.valid?
true
iex(21)> Members.Repo.insert(changeset)

13:22:38.559 [debug] QUERY OK db=9.3ms
INSERT INTO `member` (`first_name`,`last_name`,`member_id`,`inserted_at`,`updated_at`) VALUES (?,?,?,?,?) ["Jane", "Doe", "9807", {{2018, 2, 3}, {21, 22, 38, 536323}}, {{2018, 2, 3}, {21, 22, 38, 538641}}]
{:ok,
 %Members.Member{__meta__: #Ecto.Schema.Metadata<:loaded, "member">,
  birthdate: nil, first_name: "Jane", gender: nil, id: 7,
  inserted_at: ~N[2018-02-03 21:22:38.536323], last_name: "Doe",
  member_id: "9807", updated_at: ~N[2018-02-03 21:22:38.538641]}}
iex(22)>
```

The result when running the changset from the member module is an atom. Either :ok or :error, in this case, we can create a case statement to determine what should we do.

```
case Membwers.Repo.insert(changeset) do
  {:ok, member} ->
    ... do something with the member
  {:error, changeset} ->
    ... do something with the changeset
end
```

## 14. Making Queries

Lets insert some test data first.

```
members = [
  %Members.Member{member_id: "11111", first_name: "David", last_name: "Tan"},
  %Members.Member{member_id: "22222", first_name: "Susan", last_name: "Uy"},
  %Members.Member{member_id: "33333", first_name: "Martin", last_name: "Reyes"},
]

Enum.each(members, fn(m) -> Members.Repo.insert(m) end)
```

## 15. Fetching a Single record

```
Members.Member |> Ecto.Query.first |> Members.Repo.one

22:31:55.362 [debug] QUERY OK source="member" db=0.6ms
SELECT m0.`id`, m0.`member_id`, m0.`first_name`, m0.`last_name`, m0.`birthdate`, m0.`gender`, m0.`inserted_at`, m0.`updated_at` FROM `member` AS m0 ORDER BY m0.`id` LIMIT 1 []
%Members.Member{__meta__: #Ecto.Schema.Metadata<:loaded, "member">,
 birthdate: nil, first_name: "Jane", gender: nil, id: 7,
 inserted_at: ~N[2018-02-03 21:22:39.000000], last_name: "Doe",
 member_id: "9807", updated_at: ~N[2018-02-03 21:22:39.000000]}
iex(64)>

Members.Member |> Ecto.Query.last |> Members.Repo.one

```

## 16. Fetching all records

```
Members.Member |> Members.Repo.all

 %Members.Member{__meta__: #Ecto.Schema.Metadata<:loaded, "member">,
  birthdate: nil, first_name: "Jane", gender: nil, id: 8,
  inserted_at: ~N[2018-02-03 21:24:45.000000], last_name: "Doe",
  member_id: "9807", updated_at: ~N[2018-02-03 21:24:45.000000]},
 %Members.Member{__meta__: #Ecto.Schema.Metadata<:loaded, "member">,
  birthdate: nil, first_name: "David", gender: nil, id: 9,
  inserted_at: ~N[2018-02-03 21:41:41.000000], last_name: "Tan",
  member_id: "11111", updated_at: ~N[2018-02-03 21:41:41.000000]},
 %Members.Member{__meta__: #Ecto.Schema.Metadata<:loaded, "member">,
  birthdate: nil, first_name: "Susan", gender: nil, id: 10,
  inserted_at: ~N[2018-02-03 21:41:41.000000], last_name: "Uy",
  member_id: "22222", updated_at: ~N[2018-02-03 21:41:41.000000]},
 %Members.Member{__meta__: #Ecto.Schema.Metadata<:loaded, "member">,
  birthdate: nil, first_name: "Martin", gender: nil, id: 11,
  inserted_at: ~N[2018-02-03 21:41:41.000000], last_name: "Reyes",
  member_id: "33333", updated_at: ~N[2018-02-03 21:41:41.000000]}]
```

Fetching by other fields:

```
Members.Member |> Members.Repo.get_by(firstname: "Jane")
```

## 17. Fetching records based on Id

```
iex(93)> Members.Member |> Members.Repo.get(8);

22:39:37.049 [debug] QUERY OK source="member" db=0.6ms
SELECT m0.`id`, m0.`member_id`, m0.`first_name`, m0.`last_name`, m0.`birthdate`, m0.`gender`, m0.`inserted_at`, m0.`updated_at` FROM `member` AS m0 WHERE (m0.`id` = ?) [8]
%Members.Member{__meta__: #Ecto.Schema.Metadata<:loaded, "member">,
 birthdate: nil, first_name: "Jane", gender: nil, id: 8,
 inserted_at: ~N[2018-02-03 21:24:45.000000], last_name: "Doe",
 member_id: "9807", updated_at: ~N[2018-02-03 21:24:45.000000]}
```

Fetch data on a specific attribute

```
iex(111)> Members.Member |> Members.Repo.get_by(first_name: "David")

22:46:30.719 [debug] QUERY OK source="member" db=0.3ms
SELECT m0.`id`, m0.`member_id`, m0.`first_name`, m0.`last_name`, m0.`birthdate`, m0.`gender`, m0.`inserted_at`, m0.`updated_at` FROM `member` AS m0 WHERE (m0.`first_name` = ?) ["David"]
%Members.Member{__meta__: #Ecto.Schema.Metadata<:loaded, "member">,
 birthdate: nil, first_name: "David", gender: nil, id: 9,
 inserted_at: ~N[2018-02-03 21:41:41.000000], last_name: "Tan",
 member_id: "11111", updated_at: ~N[2018-02-03 21:41:41.000000]}
iex(112)>
```

## 18. Filtering results

```
import Ecto.Query

iex(6)> Members.Member |> Ecto.Query.where(last_name: "Doe") |> Members.Repo.all

22:57:29.542 [debug] QUERY OK source="member" db=2.2ms decode=2.3ms
SELECT m0.`id`, m0.`member_id`, m0.`first_name`, m0.`last_name`, m0.`birthdate`, m0.`gender`, m0.`inserted_at`, m0.`updated_at` FROM `member` AS m0 WHERE (m0.`last_name` = 'Doe') []
[%Members.Member{__meta__: #Ecto.Schema.Metadata<:loaded, "member">,
  birthdate: nil, first_name: "Jane", gender: nil, id: 7,
  inserted_at: ~N[2018-02-03 21:22:39.000000], last_name: "Doe",
  member_id: "9807", updated_at: ~N[2018-02-03 21:22:39.000000]},
 %Members.Member{__meta__: #Ecto.Schema.Metadata<:loaded, "member">,
  birthdate: nil, first_name: "Jane", gender: nil, id: 8,
  inserted_at: ~N[2018-02-03 21:24:45.000000], last_name: "Doe",
  member_id: "9807", updated_at: ~N[2018-02-03 21:24:45.000000]}]
iex(7)>
```

## 19. Updating records

First, get the record
```
iex(36)> person = Members.Member |> Ecto.Query.first |> Members.Repo.one
```

Create a change of the record
```
iex(43)> changeset = Members.Member.changeset(person, %{gender: "F"})
#Ecto.Changeset<action: nil, changes: %{}, errors: [], data: #Members.Member<>,
 valid?: true>
iex(44)>
```

Update the changes to the table
```
iex(45)> Members.Repo.update(changeset)
{:ok,
 %Members.Member{__meta__: #Ecto.Schema.Metadata<:loaded, "member">,
  birthdate: nil, first_name: "Jane", gender: "F", id: 7,
  inserted_at: ~N[2018-02-03 21:22:39.000000], last_name: "Doe",
  member_id: "9807", updated_at: ~N[2018-02-04 07:04:46.000000]}}
iex(46)>
```