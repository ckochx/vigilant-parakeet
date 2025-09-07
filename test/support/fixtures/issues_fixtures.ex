defmodule Gearflow.IssuesFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Gearflow.Issues` context.
  """

  @doc """
  Generate a request.
  """
  def request_fixture(attrs \\ %{}) do
    # Extract inserted_at if provided for direct database insertion
    {inserted_at, attrs} = Map.pop(attrs, :inserted_at)
    
    {:ok, request} =
      attrs
      |> Enum.into(%{
        attachments: [],
        description: "Final drive failure on excavator unit 12345",
        equipment_id: "CAT 320D 12345",
        needed_by: ~D[2025-09-12],
        priority: "medium",
        status: "pending"
      })
      |> Gearflow.Issues.create_request()

    # If inserted_at was provided, update the record directly in the database
    if inserted_at do
      changeset = Ecto.Changeset.change(request, inserted_at: inserted_at, updated_at: inserted_at)
      {:ok, request} = Gearflow.Repo.update(changeset)
      request
    else
      request
    end
  end
end
