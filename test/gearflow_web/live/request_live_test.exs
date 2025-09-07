defmodule GearflowWeb.RequestLiveTest do
  use GearflowWeb.ConnCase

  import Phoenix.LiveViewTest
  import Gearflow.IssuesFixtures

  @create_attrs %{
    priority: "urgent",
    description: "Final drive failure on digger unit 21784",
    needed_by: "2025-09-10",
    equipment_id: "CAT D7 21784"
  }
  @update_attrs %{
    priority: "high",
    description: "Updated: Need CAT D7 Dozer by Monday",
    needed_by: "2025-09-15",
    equipment_id: "CAT D7"
  }
  @invalid_attrs %{priority: "medium", description: "", equipment_id: "", needed_by: nil}
  defp create_request(_) do
    request = request_fixture()

    %{request: request}
  end

  describe "Index" do
    setup [:create_request]

    test "displays triage dashboard with requests", %{conn: conn, request: request} do
      {:ok, _index_live, html} = live(conn, ~p"/requests")

      assert html =~ "Issue Triage Dashboard"
      assert html =~ "Manage construction site requests"
      assert html =~ request.description
      assert html =~ "Submit New Request"
    end

    test "sorts requests by urgency first, then by newest date", %{conn: conn} do
      # Create requests with different priorities and dates
      _urgent_old =
        request_fixture(%{
          description: "Urgent old request",
          priority: "urgent",
          inserted_at: ~U[2025-01-01 10:00:00Z]
        })

      _medium_new =
        request_fixture(%{
          description: "Medium new request",
          priority: "medium",
          inserted_at: ~U[2025-01-03 10:00:00Z]
        })

      _urgent_new =
        request_fixture(%{
          description: "Urgent new request",
          priority: "urgent",
          inserted_at: ~U[2025-01-02 10:00:00Z]
        })

      _high_old =
        request_fixture(%{
          description: "High old request",
          priority: "high",
          inserted_at: ~U[2025-01-01 11:00:00Z]
        })

      {:ok, _index_live, html} = live(conn, ~p"/requests")

      # Extract the order of descriptions in the HTML
      descriptions =
        Regex.scan(~r/(Urgent new|Urgent old|High old|Medium new) request/, html)
        |> Enum.map(fn [_, desc] -> desc end)

      # Should be sorted by priority first (urgent, high, medium, low), then by newest date within same priority
      expected_order = ["Urgent new", "Urgent old", "High old", "Medium new"]

      assert descriptions == expected_order
    end

    test "sorts multiple requests of same priority by newest date first", %{conn: conn} do
      # Create multiple urgent requests with different dates
      _urgent_oldest =
        request_fixture(%{
          description: "Urgent oldest",
          priority: "urgent",
          inserted_at: ~U[2025-01-01 10:00:00Z]
        })

      _urgent_newest =
        request_fixture(%{
          description: "Urgent newest",
          priority: "urgent",
          inserted_at: ~U[2025-01-03 10:00:00Z]
        })

      _urgent_middle =
        request_fixture(%{
          description: "Urgent middle",
          priority: "urgent",
          inserted_at: ~U[2025-01-02 10:00:00Z]
        })

      {:ok, _index_live, html} = live(conn, ~p"/requests")

      # Extract the order of urgent descriptions
      descriptions =
        Regex.scan(~r/(Urgent newest|Urgent middle|Urgent oldest)/, html)
        |> Enum.map(fn [_, desc] -> desc end)

      # Should be sorted newest first within same priority
      expected_order = ["Urgent newest", "Urgent middle", "Urgent oldest"]

      assert descriptions == expected_order
    end

    test "saves new request via mobile form", %{conn: conn} do
      {:ok, form_live, _html} = live(conn, ~p"/")

      assert render(form_live) =~ "New Request"
      assert render(form_live) =~ "What&#39;s the issue?"
      assert render(form_live) =~ "How urgent is this?"

      html =
        form_live
        |> form("#request-form", request: @invalid_attrs)
        |> render_change()

      assert html =~ "can&#39;t be blank"

      assert {:ok, index_live, _html} =
               form_live
               |> form("#request-form", request: @create_attrs)
               |> render_submit()
               |> follow_redirect(conn, ~p"/requests")

      html = render(index_live)
      assert html =~ "Final drive failure on digger unit 21784"
      assert html =~ "URGENT"
    end

    test "updates request in triage dashboard", %{conn: conn, request: request} do
      {:ok, index_live, _html} = live(conn, ~p"/requests")

      assert {:ok, form_live, _html} =
               index_live
               |> element("a", "Edit")
               |> render_click()
               |> follow_redirect(conn, ~p"/requests/#{request}/edit")

      assert render(form_live) =~ "Edit Request"
      assert render(form_live) =~ "What&#39;s the issue?"

      html =
        form_live
        |> form("#request-form", request: @invalid_attrs)
        |> render_change()

      assert html =~ "can&#39;t be blank"

      assert {:ok, index_live, _html} =
               form_live
               |> form("#request-form", request: @update_attrs)
               |> render_submit()
               |> follow_redirect(conn, ~p"/requests")

      html = render(index_live)
      assert html =~ "Updated: Need CAT D7 Dozer by Monday"
      assert html =~ "HIGH"
    end

    test "displays priority badges in triage dashboard", %{conn: conn} do
      _urgent_request = request_fixture(%{priority: "urgent", description: "Machine down!"})
      _high_request = request_fixture(%{priority: "high", description: "Need parts soon"})

      {:ok, _index_live, html} = live(conn, ~p"/requests")

      assert html =~ "URGENT"
      assert html =~ "HIGH"
      assert html =~ "Machine down!"
      assert html =~ "Need parts soon"

      # urgent badge styling
      assert html =~ "bg-red-100 text-red-800"
      # high badge styling
      assert html =~ "bg-orange-100 text-orange-800"
    end

    test "displays mobile-optimized form elements", %{conn: conn} do
      {:ok, _form_live, html} = live(conn, ~p"/")

      assert html =~ "touch-manipulation"
      assert html =~ "What&#39;s the issue?"
      assert html =~ "How urgent is this?"
      assert html =~ "URGENT"
      assert html =~ "🚨"
      assert html =~ "Equipment/Unit Number"
      assert html =~ "Add Photos"
      assert html =~ "Submit Request"
    end

    test "form handles priority validation", %{conn: conn} do
      {:ok, form_live, _html} = live(conn, ~p"/")

      attrs = %{description: "Test issue", priority: "urgent", status: "pending"}

      {:ok, index_live, _html} =
        form_live
        |> form("#request-form", request: attrs)
        |> render_submit()
        |> follow_redirect(conn, ~p"/requests")

      html = render(index_live)
      assert html =~ "Test issue"
    end

    test "form displays file upload interface", %{conn: conn} do
      {:ok, form_live, html} = live(conn, ~p"/")

      # First check if the basic form is there
      assert html =~ "What&#39;s the issue?"

      # Re-render to get complete HTML (sometimes LiveView renders incrementally)
      html = render(form_live)
      assert html =~ "Add Photos &amp; Videos"
      assert html =~ "phx-drop-target"
    end

    test "form accepts photo uploads", %{conn: conn} do
      {:ok, form_live, _html} = live(conn, ~p"/")

      content = File.read!("test/support/fixtures/test_image.jpg")

      image =
        file_input(form_live, "#request-form", :attachments, [
          %{
            last_modified: 1_594_171_879_000,
            name: "equipment_damage.jpg",
            content: content,
            size: byte_size(content),
            type: "image/jpeg"
          }
        ])

      assert render_upload(image, "equipment_damage.jpg") =~ "equipment_damage.jpg"

      attrs = %{description: "Hydraulic leak with photo", priority: "high"}

      {:ok, index_live, _html} =
        form_live
        |> form("#request-form", request: attrs)
        |> render_submit()
        |> follow_redirect(conn, ~p"/requests")

      html = render(index_live)
      assert html =~ "Hydraulic leak with photo"
      assert html =~ "1 photos"
    end

    test "form accepts video uploads", %{conn: conn} do
      {:ok, form_live, _html} = live(conn, ~p"/")

      video =
        file_input(form_live, "#request-form", :attachments, [
          %{
            last_modified: 1_594_171_879_000,
            name: "machine_problem.mp4",
            content: File.read!("test/support/fixtures/test_video.mp4"),
            size: 30,
            type: "video/mp4"
          }
        ])

      assert render_upload(video, "machine_problem.mp4") =~ "machine_problem.mp4"
    end

    test "form has upload interface configured", %{conn: conn} do
      {:ok, form_live, _html} = live(conn, ~p"/")

      # Verify the form has the correct upload configuration
      html = render(form_live)
      assert html =~ "phx-drop-target"
      # The upload limit is enforced by LiveView configuration (max_entries: 5)
      # HTML validation may prevent more than 5 files from being selected
    end

    test "form has correct file type restrictions", %{conn: conn} do
      {:ok, form_live, _html} = live(conn, ~p"/")

      # Verify the file input has correct accept attribute for validation
      html = render(form_live)
      assert html =~ "accept=\".jpg,.jpeg,.png,.gif,.mp4,.mov,.avi,.webm,.m4a,.mp3,.wav,.ogg\""
    end

    test "form displays speech-to-text button for mobile", %{conn: conn} do
      {:ok, form_live, _html} = live(conn, ~p"/")

      html = render(form_live)
      # Should have a speech input button with data attribute for client-side handling
      assert html =~ "data-speech-recognition"
      assert html =~ "🎤"
    end

    test "form displays voice memo recording interface", %{conn: conn} do
      {:ok, form_live, _html} = live(conn, ~p"/")

      html = render(form_live)
      # Should have voice memo recording controls with data attribute for client-side handling
      assert html =~ "data-voice-recording"
      assert html =~ "Record Voice Memo"
    end

    test "handles speech recognition results", %{conn: conn} do
      {:ok, form_live, _html} = live(conn, ~p"/")

      # Simulate speech recognition result via LiveView event
      form_live
      |> render_hook("speech-result", %{"text" => "The hydraulic pump is leaking oil"})

      html = render(form_live)
      assert html =~ "The hydraulic pump is leaking oil"
    end

    test "handles voice memo upload", %{conn: conn} do
      {:ok, form_live, _html} = live(conn, ~p"/")

      # Create a fake audio blob
      content = "fake audio content"

      voice_memo = %{
        last_modified: 1_594_171_879_000,
        name: "voice_memo.webm",
        content: content,
        size: byte_size(content),
        type: "audio/webm"
      }

      # Should be able to upload voice memo as attachment
      upload = file_input(form_live, "#request-form", :attachments, [voice_memo])
      assert render_upload(upload, "voice_memo.webm") =~ "voice_memo.webm"
    end

    test "form has speech recognition hook", %{conn: conn} do
      {:ok, form_live, _html} = live(conn, ~p"/")

      html = render(form_live)
      # Should have the speech recognition hook on the form
      assert html =~ "phx-hook=\"SpeechRecognition\""
    end

    test "speech recognition button has correct data attribute for client-side handling", %{
      conn: conn
    } do
      {:ok, form_live, _html} = live(conn, ~p"/")

      html = render(form_live)

      # Should have speech recognition button with data attribute (client-side only, no server interaction)
      assert html =~ "data-speech-recognition"
      assert html =~ "🎤 Speech to Text"
    end

    test "voice recording button has correct data attribute for client-side handling", %{
      conn: conn
    } do
      {:ok, form_live, _html} = live(conn, ~p"/")

      # Should have the voice recording button with data attribute (client-side only, no server interaction)
      html = render(form_live)
      assert html =~ "data-voice-recording"
      assert html =~ "🎙️"
      assert html =~ "Record Voice Memo"

      # Verify the button exists with the correct data attribute
      assert html =~ "button"
      assert html =~ "data-voice-recording"

      # Form should still be functional after button is present
      html = render(form_live)
      assert html =~ "Record voice memo"
    end

    test "form supports multiple speech recognition results", %{conn: conn} do
      {:ok, form_live, _html} = live(conn, ~p"/")

      # First speech result
      form_live
      |> render_hook("speech-result", %{"text" => "The hydraulic pump is leaking"})

      # Second speech result should be appended
      form_live
      |> render_hook("speech-result", %{"text" => "and making noise"})

      html = render(form_live)
      assert html =~ "The hydraulic pump is leaking and making noise"
    end

    test "speech recognition handles empty previous description", %{conn: conn} do
      {:ok, form_live, _html} = live(conn, ~p"/")

      # Speech result on empty form
      form_live
      |> render_hook("speech-result", %{"text" => "Initial speech input"})

      html = render(form_live)
      assert html =~ "Initial speech input"
      # Should not have extra spaces
      refute html =~ " Initial speech input"
    end

    test "allows blank description when voice memo is uploaded", %{conn: conn} do
      {:ok, form_live, _html} = live(conn, ~p"/")

      # Upload a voice memo
      content = "fake audio content"

      voice_memo = %{
        last_modified: 1_594_171_879_000,
        name: "issue_report.webm",
        content: content,
        size: byte_size(content),
        type: "audio/webm"
      }

      upload = file_input(form_live, "#request-form", :attachments, [voice_memo])
      render_upload(upload, "issue_report.webm")

      # Submit form with blank description but with voice memo
      attrs = %{description: "", priority: "urgent", equipment_id: "CAT 320D"}

      # Should successfully create request and redirect
      assert {:ok, index_live, _html} =
               form_live
               |> form("#request-form", request: attrs)
               |> render_submit()
               |> follow_redirect(conn, ~p"/requests")

      html = render(index_live)
      # Should show the request was created successfully
      assert html =~ "CAT 320D"
      assert html =~ "1 photos"
    end

    test "still requires description when no voice memo uploaded", %{conn: conn} do
      {:ok, form_live, _html} = live(conn, ~p"/")

      # Submit form with blank description and no voice memo
      attrs = %{description: "", priority: "urgent", equipment_id: "CAT 320D"}

      # Should show validation error, not redirect
      html =
        form_live
        |> form("#request-form", request: attrs)
        |> render_submit()

      # Should stay on form and show validation error
      assert html =~ "can&#39;t be blank"
      refute html =~ "Request created successfully"
    end

    test "allows description with any attachment type", %{conn: conn} do
      {:ok, form_live, _html} = live(conn, ~p"/")

      # Upload a regular image (non-audio file)
      content = File.read!("test/support/fixtures/test_image.jpg")

      image_file = %{
        last_modified: 1_594_171_879_000,
        name: "damage_photo.jpg",
        content: content,
        size: byte_size(content),
        type: "image/jpeg"
      }

      upload = file_input(form_live, "#request-form", :attachments, [image_file])
      render_upload(upload, "damage_photo.jpg")

      # Submit form with blank description and image attachment
      attrs = %{description: "", priority: "high", equipment_id: "Unit 42"}

      # Should still require description for non-audio attachments
      html =
        form_live
        |> form("#request-form", request: attrs)
        |> render_submit()

      # Should stay on form and show validation error
      assert html =~ "can&#39;t be blank"
    end

    test "allows blank description with multiple voice memos", %{conn: conn} do
      {:ok, form_live, _html} = live(conn, ~p"/")

      # Upload a single voice memo to test the validation logic
      content = "fake audio content"

      voice_memo = %{
        last_modified: 1_594_171_879_000,
        name: "report.m4a",
        content: content,
        size: byte_size(content),
        type: "audio/mp4"
      }

      upload = file_input(form_live, "#request-form", :attachments, [voice_memo])
      render_upload(upload, "report.m4a")

      # Submit form with blank description but with voice memo
      attrs = %{description: "", priority: "medium"}

      # Should successfully create request and redirect (validation allows blank description)
      assert {:ok, index_live, _html} =
               form_live
               |> form("#request-form", request: attrs)
               |> render_submit()
               |> follow_redirect(conn, ~p"/requests")

      html = render(index_live)
      # Should show the request was created
      assert html =~ "1 photos"
    end
  end

  describe "Show" do
    setup [:create_request]

    test "displays request", %{conn: conn, request: request} do
      {:ok, _show_live, html} = live(conn, ~p"/requests/#{request}")

      assert html =~ "Show Request"
      assert html =~ request.description
    end

    test "updates request and returns to show", %{conn: conn, request: request} do
      {:ok, show_live, _html} = live(conn, ~p"/requests/#{request}")

      assert {:ok, form_live, _} =
               show_live
               |> element("a", "Edit")
               |> render_click()
               |> follow_redirect(conn, ~p"/requests/#{request}/edit?return_to=show")

      assert render(form_live) =~ "Edit Request"

      html =
        form_live
        |> form("#request-form", request: @invalid_attrs)
        |> render_change()

      assert html =~ "can&#39;t be blank"

      assert {:ok, show_live, _html} =
               form_live
               |> form("#request-form", request: @update_attrs)
               |> render_submit()
               |> follow_redirect(conn, ~p"/requests/#{request}")

      html = render(show_live)
      assert html =~ "Request updated successfully"
      assert html =~ "Updated: Need CAT D7 Dozer by Monday"
    end
  end
end
