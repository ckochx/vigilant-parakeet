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
        attachments: ["option1", "option2"],
        description: "some description",
        equipment_id: "some equipment_id",
        needed_by: ~D[2025-09-05],
        priority: "some priority",
        status: "some status"
      })
      |> Gearflow.Issues.create_request()

    request
  end
end
