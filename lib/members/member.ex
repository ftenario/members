defmodule Members.Member do
    use Ecto.Schema

    schema "member" do
        field :member_id, :string
        field :first_name, :string
        field :last_name, :string
        field :birthdate, Timex.Ecto.Date 
        field :gender, :string
        timestamps()
    end
end
