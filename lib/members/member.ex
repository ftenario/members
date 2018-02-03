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

    def changeset(member, params \\ %{}) do
        member
        |> Ecto.Changeset.cast(params, [:member_id, :first_name, :last_name, :birthdate, :gender])
        |> Ecto.Changeset.validate_required([:member_id, :first_name, :last_name])
    end  
    
end
