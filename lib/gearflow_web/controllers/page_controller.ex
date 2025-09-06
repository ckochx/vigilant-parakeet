defmodule GearflowWeb.PageController do
  use GearflowWeb, :controller

  def home(conn, _params) do
    render(conn, :home)
  end
end
