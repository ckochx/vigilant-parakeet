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
