defmodule Gearflow.IssuesTest do
  use Gearflow.DataCase

  alias Gearflow.Issues

  describe "requests" do
    alias Gearflow.Issues.Request

    import Gearflow.IssuesFixtures

    @invalid_attrs %{priority: "medium", description: "", equipment_id: "", needed_by: nil}

    test "list_requests/0 returns all requests" do
      request = request_fixture()
      assert Issues.list_requests() == [request]
    end

    test "get_request!/1 returns the request with given id" do
      request = request_fixture()
      assert Issues.get_request!(request.id) == request
    end

    test "create_request/1 with valid data creates a request" do
      valid_attrs = %{
        priority: "urgent",
        status: "pending",
        description: "Hydraulic pump failure on dozer unit 5521",
        attachments: [],
        needed_by: ~D[2025-09-08],
        equipment_id: "CAT D6T 5521"
      }

      assert {:ok, %Request{} = request} = Issues.create_request(valid_attrs)
      assert request.priority == "urgent"
      assert request.status == "pending"
      assert request.description == "Hydraulic pump failure on dozer unit 5521"
      assert request.attachments == []
      assert request.needed_by == ~D[2025-09-08]
      assert request.equipment_id == "CAT D6T 5521"
    end

    test "create_request/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Issues.create_request(@invalid_attrs)
    end

    test "update_request/2 with valid data updates the request" do
      request = request_fixture()

      update_attrs = %{
        priority: "high",
        status: "in_progress",
        description: "Need replacement tracks for excavator",
        attachments: [],
        needed_by: ~D[2025-09-15],
        equipment_id: "CAT 320D"
      }

      assert {:ok, %Request{} = request} = Issues.update_request(request, update_attrs)
      assert request.priority == "high"
      assert request.status == "in_progress"
      assert request.description == "Need replacement tracks for excavator"
      assert request.attachments == []
      assert request.needed_by == ~D[2025-09-15]
      assert request.equipment_id == "CAT 320D"
    end

    test "update_request/2 with invalid data returns error changeset" do
      request = request_fixture()
      assert {:error, %Ecto.Changeset{}} = Issues.update_request(request, @invalid_attrs)
      assert request == Issues.get_request!(request.id)
    end

    test "delete_request/1 deletes the request" do
      request = request_fixture()
      assert {:ok, %Request{}} = Issues.delete_request(request)
      assert_raise Ecto.NoResultsError, fn -> Issues.get_request!(request.id) end
    end

    test "change_request/1 returns a request changeset" do
      request = request_fixture()
      assert %Ecto.Changeset{} = Issues.change_request(request)
    end

    test "create_request/1 with construction-specific data" do
      attrs = %{
        priority: "urgent",
        status: "pending",
        description: "I have a final drive failure on a digger unit 21784",
        equipment_id: "digger unit 21784",
        needed_by: ~D[2025-09-07]
      }

      assert {:ok, %Request{} = request} = Issues.create_request(attrs)
      assert request.priority == "urgent"
      assert request.description == "I have a final drive failure on a digger unit 21784"
      assert request.equipment_id == "digger unit 21784"
    end

    test "create_request/1 with dozer request data" do
      attrs = %{
        priority: "high",
        status: "pending",
        description: "I need a CAT D7 Dozer by next Monday",
        equipment_id: "CAT D7",
        needed_by: ~D[2025-09-09]
      }

      assert {:ok, %Request{} = request} = Issues.create_request(attrs)
      assert request.description == "I need a CAT D7 Dozer by next Monday"
      assert request.equipment_id == "CAT D7"
      assert request.priority == "high"
    end

    test "list_requests/0 returns multiple requests with different priorities" do
      _urgent = request_fixture(%{priority: "urgent", description: "Urgent issue"})
      _high = request_fixture(%{priority: "high", description: "High priority"})
      _medium = request_fixture(%{priority: "medium", description: "Medium priority"})

      requests = Issues.list_requests()

      assert length(requests) == 3
      descriptions = Enum.map(requests, & &1.description)
      assert "Urgent issue" in descriptions
      assert "High priority" in descriptions
      assert "Medium priority" in descriptions
    end
  end
end
