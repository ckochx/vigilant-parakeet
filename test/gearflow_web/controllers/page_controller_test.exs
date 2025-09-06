defmodule GearflowWeb.PageControllerTest do
  use GearflowWeb.ConnCase
  import Phoenix.LiveViewTest

  test "GET / shows request form", %{conn: conn} do
    {:ok, _live, html} = live(conn, ~p"/")
    assert html =~ "New Request"
    assert html =~ "What&#39;s the issue?"
  end
end
