defmodule Gearflow.Repo.Migrations.CreateRequests do
  use Ecto.Migration

  def change do
    create table(:requests) do
      add :description, :text
      add :priority, :string
      add :status, :string
      add :attachments, {:array, :string}
      add :needed_by, :date
      add :equipment_id, :string

      timestamps(type: :utc_datetime)
    end
  end
end
