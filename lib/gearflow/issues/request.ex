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
    |> validate_required([:description])
    |> validate_inclusion(:priority, ["urgent", "high", "medium", "low"],
      message: "must be one of: urgent, high, medium, low"
    )
    |> maybe_put_defaults()
  end

  defp maybe_put_defaults(changeset) do
    changeset
    |> put_change(:status, get_change(changeset, :status) || "pending")
    |> put_change(:attachments, get_change(changeset, :attachments) || [])
  end
end
