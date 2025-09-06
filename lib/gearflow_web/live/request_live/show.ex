defmodule GearflowWeb.RequestLive.Show do
  use GearflowWeb, :live_view

  alias Gearflow.Issues

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <.header>
        Request {@request.id}
        <:subtitle>This is a request record from your database.</:subtitle>
        <:actions>
          <.button navigate={~p"/requests"}>
            <.icon name="hero-arrow-left" />
          </.button>
          <.button variant="primary" navigate={~p"/requests/#{@request}/edit?return_to=show"}>
            <.icon name="hero-pencil-square" /> Edit request
          </.button>
        </:actions>
      </.header>

      <.list>
        <:item title="Description">{@request.description}</:item>
        <:item title="Priority">{@request.priority}</:item>
        <:item title="Status">{@request.status}</:item>
        <:item title="Attachments">{@request.attachments}</:item>
        <:item title="Needed by">{@request.needed_by}</:item>
        <:item title="Equipment">{@request.equipment_id}</:item>
      </.list>
    </Layouts.app>
    """
  end

  @impl true
  def mount(%{"id" => id}, _session, socket) do
    {:ok,
     socket
     |> assign(:page_title, "Show Request")
     |> assign(:request, Issues.get_request!(id))}
  end
end
