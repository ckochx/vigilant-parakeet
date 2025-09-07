defmodule GearflowWeb.RequestLive.Index do
  use GearflowWeb, :live_view

  alias Gearflow.Issues

  @impl true
  def render(assigns) do
    ~H"""
    <div class="min-h-screen bg-gray-50 px-4 py-6">
      <div id="flash-messages" aria-live="polite" class="mb-4 max-w-4xl mx-auto">
        <%= if Phoenix.Flash.get(@flash, :info) do %>
          <div class="bg-green-100 border border-green-400 text-green-700 px-4 py-3 rounded-lg mb-4" role="alert">
            <div class="flex">
              <.icon name="hero-check-circle" class="w-5 h-5 mr-2 mt-0.5" />
              <span>{Phoenix.Flash.get(@flash, :info)}</span>
            </div>
          </div>
        <% end %>
        <%= if Phoenix.Flash.get(@flash, :error) do %>
          <div class="bg-red-100 border border-red-400 text-red-700 px-4 py-3 rounded-lg mb-4" role="alert">
            <div class="flex">
              <.icon name="hero-exclamation-circle" class="w-5 h-5 mr-2 mt-0.5" />
              <span>{Phoenix.Flash.get(@flash, :error)}</span>
            </div>
          </div>
        <% end %>
      </div>
      <div class="max-w-4xl mx-auto">
        <div class="bg-white rounded-lg shadow-sm p-6 mb-6">
          <h1 class="text-2xl font-bold text-gray-900 mb-2">Issue Triage Dashboard</h1>
          <p class="text-gray-600 mb-4">Manage construction site requests and issues</p>

          <.link
            navigate={~p"/"}
            class="inline-flex items-center px-6 py-3 bg-blue-600 text-white font-medium rounded-lg hover:bg-blue-700 touch-manipulation"
          >
            <.icon name="hero-plus" class="w-5 h-5 mr-2" /> Submit New Request
          </.link>
        </div>

        <div class="grid gap-4">
          <div
            :for={{_id, request} <- @streams.requests}
            class="bg-white rounded-lg shadow-sm border-l-4 p-4 hover:shadow-md transition-shadow"
            class={[
              request.priority == "urgent" && "border-red-500",
              request.priority == "high" && "border-orange-500",
              request.priority == "medium" && "border-yellow-500",
              request.priority == "low" && "border-green-500"
            ]}
          >
            <div class="flex justify-between items-start mb-3">
              <div class="flex items-center gap-2">
                <span class={[
                  "px-2 py-1 text-xs font-medium rounded-full",
                  request.priority == "urgent" && "bg-red-100 text-red-800",
                  request.priority == "high" && "bg-orange-100 text-orange-800",
                  request.priority == "medium" && "bg-yellow-100 text-yellow-800",
                  request.priority == "low" && "bg-green-100 text-green-800"
                ]}>
                  {String.upcase(request.priority || "MEDIUM")}
                </span>
                <span class={[
                  "px-2 py-1 text-xs font-medium rounded-full",
                  request.status == "pending" && "bg-gray-100 text-gray-800",
                  request.status == "in_progress" && "bg-blue-100 text-blue-800",
                  request.status == "completed" && "bg-green-100 text-green-800"
                ]}>
                  {String.upcase(request.status || "PENDING")}
                </span>
              </div>
              <div class="text-xs text-gray-500">
                {if request.needed_by, do: "Due: #{request.needed_by}"}
              </div>
            </div>

            <p class="text-gray-900 font-medium mb-2 line-clamp-2">{request.description}</p>

            <div class="flex flex-wrap gap-2 text-sm text-gray-600 mb-3">
              <div :if={request.equipment_id} class="flex items-center gap-1">
                <.icon name="hero-wrench-screwdriver" class="w-4 h-4" />
                {request.equipment_id}
              </div>
              <div
                :if={request.attachments && length(request.attachments) > 0}
                class="flex items-center gap-1"
              >
                <.icon name="hero-camera" class="w-4 h-4" />
                {length(request.attachments)} photos
              </div>
            </div>

            <div class="flex gap-2">
              <.link
                navigate={~p"/requests/#{request}"}
                class="flex-1 text-center px-4 py-2 bg-gray-100 text-gray-700 rounded-md hover:bg-gray-200 text-sm font-medium touch-manipulation"
              >
                View Details
              </.link>
              <.link
                navigate={~p"/requests/#{request}/edit"}
                class="flex-1 text-center px-4 py-2 bg-blue-100 text-blue-700 rounded-md hover:bg-blue-200 text-sm font-medium touch-manipulation"
              >
                Edit
              </.link>
            </div>
          </div>
        </div>
      </div>
    </div>
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
