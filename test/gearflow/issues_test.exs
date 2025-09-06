defmodule Gearflow.IssuesTest do
  use Gearflow.DataCase

  alias Gearflow.Issues

  describe "requests" do
    alias Gearflow.Issues.Request

    import Gearflow.IssuesFixtures

    @invalid_attrs %{priority: nil, status: nil, description: nil, attachments: nil, needed_by: nil, equipment_id: nil}

    test "list_requests/0 returns all requests" do
      request = request_fixture()
      assert Issues.list_requests() == [request]
    end

    test "get_request!/1 returns the request with given id" do
      request = request_fixture()
      assert Issues.get_request!(request.id) == request
    end

    test "create_request/1 with valid data creates a request" do
      valid_attrs = %{priority: "some priority", status: "some status", description: "some description", attachments: ["option1", "option2"], needed_by: ~D[2025-09-05], equipment_id: "some equipment_id"}

      assert {:ok, %Request{} = request} = Issues.create_request(valid_attrs)
      assert request.priority == "some priority"
      assert request.status == "some status"
      assert request.description == "some description"
      assert request.attachments == ["option1", "option2"]
      assert request.needed_by == ~D[2025-09-05]
      assert request.equipment_id == "some equipment_id"
    end

    test "create_request/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Issues.create_request(@invalid_attrs)
    end

    test "update_request/2 with valid data updates the request" do
      request = request_fixture()
      update_attrs = %{priority: "some updated priority", status: "some updated status", description: "some updated description", attachments: ["option1"], needed_by: ~D[2025-09-06], equipment_id: "some updated equipment_id"}

      assert {:ok, %Request{} = request} = Issues.update_request(request, update_attrs)
      assert request.priority == "some updated priority"
      assert request.status == "some updated status"
      assert request.description == "some updated description"
      assert request.attachments == ["option1"]
      assert request.needed_by == ~D[2025-09-06]
      assert request.equipment_id == "some updated equipment_id"
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
  end
end
