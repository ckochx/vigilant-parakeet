defmodule GearflowWeb.RequestLiveTest do
  use GearflowWeb.ConnCase

  import Phoenix.LiveViewTest
  import Gearflow.IssuesFixtures

  @create_attrs %{priority: "some priority", status: "some status", description: "some description", attachments: ["option1", "option2"], needed_by: "2025-09-05", equipment_id: "some equipment_id"}
  @update_attrs %{priority: "some updated priority", status: "some updated status", description: "some updated description", attachments: ["option1"], needed_by: "2025-09-06", equipment_id: "some updated equipment_id"}
  @invalid_attrs %{priority: nil, status: nil, description: nil, attachments: [], needed_by: nil, equipment_id: nil}
  defp create_request(_) do
    request = request_fixture()

    %{request: request}
  end

  describe "Index" do
    setup [:create_request]

    test "lists all requests", %{conn: conn, request: request} do
      {:ok, _index_live, html} = live(conn, ~p"/requests")

      assert html =~ "Listing Requests"
      assert html =~ request.description
    end

    test "saves new request", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, ~p"/requests")

      assert {:ok, form_live, _} =
               index_live
               |> element("a", "New Request")
               |> render_click()
               |> follow_redirect(conn, ~p"/requests/new")

      assert render(form_live) =~ "New Request"

      assert form_live
             |> form("#request-form", request: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert {:ok, index_live, _html} =
               form_live
               |> form("#request-form", request: @create_attrs)
               |> render_submit()
               |> follow_redirect(conn, ~p"/requests")

      html = render(index_live)
      assert html =~ "Request created successfully"
      assert html =~ "some description"
    end

    test "updates request in listing", %{conn: conn, request: request} do
      {:ok, index_live, _html} = live(conn, ~p"/requests")

      assert {:ok, form_live, _html} =
               index_live
               |> element("#requests-#{request.id} a", "Edit")
               |> render_click()
               |> follow_redirect(conn, ~p"/requests/#{request}/edit")

      assert render(form_live) =~ "Edit Request"

      assert form_live
             |> form("#request-form", request: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert {:ok, index_live, _html} =
               form_live
               |> form("#request-form", request: @update_attrs)
               |> render_submit()
               |> follow_redirect(conn, ~p"/requests")

      html = render(index_live)
      assert html =~ "Request updated successfully"
      assert html =~ "some updated description"
    end

    test "deletes request in listing", %{conn: conn, request: request} do
      {:ok, index_live, _html} = live(conn, ~p"/requests")

      assert index_live |> element("#requests-#{request.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#requests-#{request.id}")
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

      assert form_live
             |> form("#request-form", request: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert {:ok, show_live, _html} =
               form_live
               |> form("#request-form", request: @update_attrs)
               |> render_submit()
               |> follow_redirect(conn, ~p"/requests/#{request}")

      html = render(show_live)
      assert html =~ "Request updated successfully"
      assert html =~ "some updated description"
    end
  end
end
