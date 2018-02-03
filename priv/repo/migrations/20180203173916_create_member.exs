defmodule Members.Repo.Migrations.CreateMember do
  use Ecto.Migration

  def change do
    create table(:member) do
      add :member_id, :string
      add :first_name, :string
      add :last_name, :string
      add :birthdate, :date
      add :gender, :string 

      timestamps()
    end

  end
end
