defmodule GearflowWeb.RequestLive.Index do
  use GearflowWeb, :live_view

  alias Gearflow.Issues

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <.header>
        Listing Requests
        <:actions>
          <.button variant="primary" navigate={~p"/requests/new"}>
            <.icon name="hero-plus" /> New Request
          </.button>
        </:actions>
      </.header>

      <.table
        id="requests"
        rows={@streams.requests}
        row_click={fn {_id, request} -> JS.navigate(~p"/requests/#{request}") end}
      >
        <:col :let={{_id, request}} label="Description">{request.description}</:col>
        <:col :let={{_id, request}} label="Priority">{request.priority}</:col>
        <:col :let={{_id, request}} label="Status">{request.status}</:col>
        <:col :let={{_id, request}} label="Attachments">{request.attachments}</:col>
        <:col :let={{_id, request}} label="Needed by">{request.needed_by}</:col>
        <:col :let={{_id, request}} label="Equipment">{request.equipment_id}</:col>
        <:action :let={{_id, request}}>
          <div class="sr-only">
            <.link navigate={~p"/requests/#{request}"}>Show</.link>
          </div>
          <.link navigate={~p"/requests/#{request}/edit"}>Edit</.link>
        </:action>
        <:action :let={{id, request}}>
          <.link
            phx-click={JS.push("delete", value: %{id: request.id}) |> hide("##{id}")}
            data-confirm="Are you sure?"
          >
            Delete
          </.link>
        </:action>
      </.table>
    </Layouts.app>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(:page_title, "Listing Requests")
     |> stream(:requests, list_requests())}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    request = Issues.get_request!(id)
    {:ok, _} = Issues.delete_request(request)

    {:noreply, stream_delete(socket, :requests, request)}
  end

  defp list_requests() do
    Issues.list_requests()
  end
end
