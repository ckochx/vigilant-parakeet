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

  describe "Triage Show" do
    test "displays request details in triage format", %{conn: conn} do
      request =
        request_fixture(%{
          description: "Hydraulic system failure on excavator",
          priority: "urgent",
          status: "pending",
          equipment_id: "CAT 320D 12345",
          needed_by: ~D[2025-09-15],
          attachments: ["/uploads/test-image.jpg"]
        })

      {:ok, _show_live, html} = live(conn, ~p"/triage/#{request}")

      assert html =~ "Triage Review"
      assert html =~ "Request ##{request.id}"
      assert html =~ "Hydraulic system failure"
      assert html =~ "URGENT"
      assert html =~ "PENDING"
      assert html =~ "CAT 320D 12345"
      assert html =~ "September 15, 2025"
      assert html =~ "1 attachment"
    end

    test "shows admin-specific styling and navigation", %{conn: conn} do
      request = request_fixture(%{description: "Test admin styling"})

      {:ok, _show_live, html} = live(conn, ~p"/triage/#{request}")

      assert html =~ "Admin Dashboard"
      assert html =~ "bg-slate-"
      assert html =~ "← Back to Triage"
      assert html =~ "Edit Request"
    end

    test "allows status updates directly from triage show", %{conn: conn} do
      request = request_fixture(%{description: "Test status update", status: "pending"})

      {:ok, show_live, _html} = live(conn, ~p"/triage/#{request}")

      # Update status to in_progress
      assert show_live
             |> element("[phx-click='update_status'][phx-value-status='in_progress']")
             |> render_click()

      # Verify the status was updated
      updated_html = render(show_live)
      assert updated_html =~ "IN_PROGRESS"
      assert updated_html =~ "Status updated"
    end

    test "allows priority updates directly from triage show", %{conn: conn} do
      request = request_fixture(%{description: "Test priority update", priority: "medium"})

      {:ok, show_live, _html} = live(conn, ~p"/triage/#{request}")

      # Update priority to urgent
      assert show_live
             |> element("[phx-click='update_priority'][phx-value-priority='urgent']")
             |> render_click()

      # Verify the priority was updated
      updated_html = render(show_live)
      assert updated_html =~ "URGENT"
      assert updated_html =~ "Priority updated"
    end

    test "shows attachment details with admin controls", %{conn: conn} do
      request =
        request_fixture(%{
          description: "Test with attachments",
          attachments: ["/uploads/image.jpg", "/uploads/video.mp4", "/uploads/voice_memo.webm"]
        })

      {:ok, _show_live, html} = live(conn, ~p"/triage/#{request}")

      assert html =~ "3 attachments"
      assert html =~ "Image"
      assert html =~ "Video"
      assert html =~ "Voice Memo"
    end

    test "provides quick action buttons for common triage tasks", %{conn: conn} do
      request = request_fixture(%{description: "Test quick actions"})

      {:ok, _show_live, html} = live(conn, ~p"/triage/#{request}")

      assert html =~ "Mark Complete"
      assert html =~ "Assign Priority"
      assert html =~ "Add Notes"
      assert html =~ "Edit Request"
    end

    test "navigates back to triage index", %{conn: conn} do
      request = request_fixture(%{description: "Test navigation"})

      {:ok, show_live, _html} = live(conn, ~p"/triage/#{request}")

      assert {:ok, _index_live, html} =
               show_live
               |> element("a", "← Back to Triage")
               |> render_click()
               |> follow_redirect(conn, ~p"/triage")

      assert html =~ "Issue Triage Dashboard"
    end

    test "displays images inline with toggle functionality", %{conn: conn} do
      request =
        request_fixture(%{
          description: "Test with image attachments",
          attachments: ["/uploads/image.jpg", "/uploads/photo.png", "/uploads/video.mp4"]
        })

      {:ok, show_live, html} = live(conn, ~p"/triage/#{request}")

      # Should show image file names and toggle buttons
      assert html =~ "image.jpg"
      assert html =~ "photo.png"
      assert html =~ "video.mp4"
      # Toggle button for images
      assert html =~ "Show"

      # Initially images should be collapsed
      refute html =~ "<img"

      # Click to expand first image
      assert show_live
             |> element("[phx-click='toggle_image'][phx-value-index='0']")
             |> render_click()

      # Now should show the image
      updated_html = render(show_live)
      assert updated_html =~ "<img"
      assert updated_html =~ "/uploads/image.jpg"
      # Button should now show "Hide"
      assert updated_html =~ "Hide"
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
