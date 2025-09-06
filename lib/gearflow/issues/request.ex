defmodule Gearflow.Issues.Request do
  use Ecto.Schema
  import Ecto.Changeset

  schema "requests" do
    field :description, :string
    field :priority, :string
    field :status, :string
    field :attachments, {:array, :string}
    field :needed_by, :date
    field :equipment_id, :string

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(request, attrs) do
    request
    |> cast(attrs, [:description, :priority, :status, :attachments, :needed_by, :equipment_id])
    |> validate_required([:description, :priority, :status, :attachments, :needed_by, :equipment_id])
  end
end
