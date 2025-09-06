defmodule Gearflow.IssuesFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Gearflow.Issues` context.
  """

  @doc """
  Generate a request.
  """
  def request_fixture(attrs \\ %{}) do
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

    request
  end
end
