defmodule GearflowWeb.TriageLiveTest do
  use GearflowWeb.ConnCase

  import Phoenix.LiveViewTest
  import Gearflow.IssuesFixtures

  describe "Triage Index" do
    test "lists all requests for triage", %{conn: conn} do
      request =
        request_fixture(%{description: "Test issue", priority: "urgent", status: "pending"})

      {:ok, _index_live, html} = live(conn, ~p"/triage")

      assert html =~ "Issue Triage Dashboard"
      assert html =~ request.description
      assert html =~ "URGENT"
      assert html =~ "PENDING"
    end

    test "updates request status", %{conn: conn} do
      request = request_fixture(%{description: "Test issue", status: "pending"})

      {:ok, index_live, _html} = live(conn, ~p"/triage")

      # Update status to in_progress
      assert index_live
             |> element(
               "[phx-click='update_status'][phx-value-id='#{request.id}'][phx-value-status='in_progress']"
             )
             |> render_click()

      # Verify the status was updated
      updated_html = render(index_live)
      assert updated_html =~ "IN_PROGRESS"
    end

    test "sorts requests by priority", %{conn: conn} do
      _low = request_fixture(%{description: "Low priority", priority: "low"})
      _urgent = request_fixture(%{description: "Urgent issue", priority: "urgent"})
      _medium = request_fixture(%{description: "Medium issue", priority: "medium"})

      {:ok, _index_live, html} = live(conn, ~p"/triage")

      # Extract request descriptions in order they appear
      descriptions =
        Regex.scan(~r/(Urgent issue|Medium issue|Low priority)/, html)
        |> Enum.map(fn [_, desc] -> desc end)

      # Should be sorted by priority: urgent, then medium, then low
      assert descriptions == ["Urgent issue", "Medium issue", "Low priority"]
    end

    test "deletes request from triage", %{conn: conn} do
      request = request_fixture(%{description: "Test request to delete"})

      {:ok, index_live, _html} = live(conn, ~p"/triage")

      # Verify request is present
      assert render(index_live) =~ "Test request to delete"

      # Delete the request
      assert index_live
             |> element("[phx-click='delete_request'][phx-value-id='#{request.id}']")
             |> render_click()

      # Verify request is removed from the view
      refute render(index_live) =~ "Test request to delete"

      # Verify flash message
      assert render(index_live) =~ "Request deleted successfully"
    end
  end

  describe "Triage Edit" do
    test "displays edit form for request", %{conn: conn} do
      request = request_fixture(%{description: "Test edit", priority: "high", status: "pending"})

      {:ok, _edit_live, html} = live(conn, ~p"/triage/#{request}/edit")

      assert html =~ "Edit Request #{request.id}"
      assert html =~ "Test edit"
      assert html =~ "HIGH"
      assert html =~ "PENDING"
    end

    test "updates request status", %{conn: conn} do
      request = request_fixture(%{description: "Test status update", status: "pending"})

      {:ok, edit_live, _html} = live(conn, ~p"/triage/#{request}/edit")

      # Update status to completed
      assert {:ok, _index_live, html} =
               edit_live
               |> form("#triage-edit-form", request: %{status: "completed"})
               |> render_submit()
               |> follow_redirect(conn, ~p"/triage")

      assert html =~ "Request updated successfully"
      assert html =~ "COMPLETED"
    end

    test "updates request priority", %{conn: conn} do
      request = request_fixture(%{description: "Test priority update", priority: "medium"})

      {:ok, edit_live, _html} = live(conn, ~p"/triage/#{request}/edit")

      # Update priority to urgent
      assert {:ok, _index_live, html} =
               edit_live
               |> form("#triage-edit-form", request: %{priority: "urgent"})
               |> render_submit()
               |> follow_redirect(conn, ~p"/triage")

      assert html =~ "Request updated successfully"
      assert html =~ "URGENT"
    end

    test "deletes request from edit page", %{conn: conn} do
      request = request_fixture(%{description: "Test delete from edit"})

      {:ok, edit_live, _html} = live(conn, ~p"/triage/#{request}/edit")

      # Delete the request
      assert {:ok, _index_live, html} =
               edit_live
               |> element("[phx-click='delete_request']")
               |> render_click()
               |> follow_redirect(conn, ~p"/triage")

      assert html =~ "Request deleted successfully"
      refute html =~ "Test delete from edit"
    end

    test "validates required fields", %{conn: conn} do
      request = request_fixture(%{description: "Test validation"})

      {:ok, edit_live, _html} = live(conn, ~p"/triage/#{request}/edit")

      # Try to submit with empty description
      html =
        edit_live
        |> form("#triage-edit-form", request: %{description: ""})
        |> render_change()

      assert html =~ "can&#39;t be blank"
    end
  end
end
