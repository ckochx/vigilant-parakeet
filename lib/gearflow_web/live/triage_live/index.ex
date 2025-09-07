defmodule GearflowWeb.TriageLive.Index do
  use GearflowWeb, :live_view

  alias Gearflow.Issues

  @impl true
  def render(assigns) do
    ~H"""
    <div class="min-h-screen bg-slate-100 px-4 py-6">
      <!-- Admin Header Bar -->
      <div class="bg-slate-800 text-white px-6 py-3 mb-6 -mx-4">
        <div class="max-w-6xl mx-auto flex items-center justify-between">
          <div class="flex items-center gap-3">
            <.icon name="hero-cog-6-tooth" class="w-6 h-6 text-slate-300" />
            <span class="text-lg font-semibold">Admin Dashboard</span>
            <span class="text-sm text-slate-300">/ Issue Triage</span>
          </div>
          <div class="flex items-center gap-4">
            <.link
              navigate={~p"/requests"}
              class="text-sm text-slate-300 hover:text-white"
            >
              View Public Dashboard
            </.link>
          </div>
        </div>
      </div>

      <div id="flash-messages" aria-live="polite" class="mb-4 max-w-6xl mx-auto">
        <%= if Phoenix.Flash.get(@flash, :info) do %>
          <div
            class="bg-emerald-100 border border-emerald-400 text-emerald-700 px-4 py-3 rounded-lg mb-4"
            role="alert"
          >
            <div class="flex">
              <.icon name="hero-check-circle" class="w-5 h-5 mr-2 mt-0.5" />
              <span>{Phoenix.Flash.get(@flash, :info)}</span>
            </div>
          </div>
        <% end %>
        <%= if Phoenix.Flash.get(@flash, :error) do %>
          <div
            class="bg-red-100 border border-red-400 text-red-700 px-4 py-3 rounded-lg mb-4"
            role="alert"
          >
            <div class="flex">
              <.icon name="hero-exclamation-circle" class="w-5 h-5 mr-2 mt-0.5" />
              <span>{Phoenix.Flash.get(@flash, :error)}</span>
            </div>
          </div>
        <% end %>
      </div>

      <div class="max-w-6xl mx-auto">
        <div class="bg-white rounded-lg shadow-md border-l-4 border-slate-600 p-6 mb-6">
          <div class="flex items-center justify-between mb-4">
            <div>
              <h1 class="text-2xl font-bold text-slate-900 mb-2">Issue Triage Management</h1>
              <p class="text-slate-600">Review, manage, and process incoming maintenance requests</p>
            </div>
            <div class="flex items-center gap-3">
              <div class="text-right text-sm text-slate-500">
                <div>Total Requests</div>
                <div class="text-lg font-semibold text-slate-700">{@request_count}</div>
              </div>
              <.link
                navigate={~p"/"}
                class="inline-flex items-center px-4 py-2 bg-slate-600 text-white font-medium rounded-lg hover:bg-slate-700 touch-manipulation"
              >
                <.icon name="hero-plus" class="w-5 h-5 mr-2" /> New Request
              </.link>
            </div>
          </div>
        </div>

        <div class="grid gap-4">
          <div
            :for={{_id, request} <- @streams.requests}
            class="bg-white rounded-lg shadow-md border border-slate-200 p-6 hover:shadow-lg transition-all duration-200"
          >
            <!-- Admin Header Row -->
            <div class="flex items-center justify-between mb-3 pb-3 border-b border-slate-100">
              <div class="flex items-center gap-3">
                <div class={[
                  "w-3 h-3 rounded-full",
                  request.priority == "urgent" && "bg-red-500 animate-pulse",
                  request.priority == "high" && "bg-orange-500",
                  request.priority == "medium" && "bg-yellow-500",
                  request.priority == "low" && "bg-green-500"
                ]}>
                </div>
                <span class="text-sm font-mono text-slate-500">ID #{request.id}</span>
                <span class="text-xs text-slate-400">
                  {Calendar.strftime(request.inserted_at, "%m/%d/%y %I:%M %p")}
                </span>
              </div>
              <div class="text-sm text-slate-500">
                {if request.needed_by, do: "Due: #{request.needed_by}"}
              </div>
            </div>
            <!-- Priority and Status Row -->
            <div class="flex items-center gap-4 mb-4">
              <div class="flex items-center gap-2">
                <span class="text-xs font-medium text-slate-500">PRIORITY</span>
                <span class={[
                  "px-2 py-1 text-xs font-bold rounded border",
                  request.priority == "urgent" && "bg-red-50 text-red-700 border-red-200",
                  request.priority == "high" && "bg-orange-50 text-orange-700 border-orange-200",
                  request.priority == "medium" && "bg-yellow-50 text-yellow-700 border-yellow-200",
                  request.priority == "low" && "bg-green-50 text-green-700 border-green-200"
                ]}>
                  {String.upcase(request.priority || "MEDIUM")}
                </span>
              </div>
              <div class="flex items-center gap-2">
                <span class="text-xs font-medium text-slate-500">STATUS</span>
                <span class={[
                  "px-2 py-1 text-xs font-bold rounded border",
                  request.status == "pending" && "bg-slate-50 text-slate-700 border-slate-200",
                  request.status == "in_progress" && "bg-blue-50 text-blue-700 border-blue-200",
                  request.status == "completed" && "bg-emerald-50 text-emerald-700 border-emerald-200"
                ]}>
                  {String.upcase(request.status || "PENDING")}
                </span>
              </div>
            </div>
            
    <!-- Description -->
            <div class="mb-4">
              <h3 class="text-base font-medium text-slate-900 mb-2">Description</h3>
              <p class="text-slate-700 bg-slate-50 p-3 rounded border text-sm leading-relaxed">
                {request.description}
              </p>
            </div>
            
    <!-- Metadata Grid -->
            <div class="grid grid-cols-2 gap-4 mb-4 p-3 bg-slate-50 rounded border">
              <div :if={request.equipment_id}>
                <div class="text-xs font-medium text-slate-500 mb-1">EQUIPMENT</div>
                <div class="flex items-center gap-2 text-sm text-slate-700">
                  <.icon name="hero-wrench-screwdriver" class="w-4 h-4 text-slate-500" />
                  {request.equipment_id}
                </div>
              </div>
              <div :if={request.attachments && length(request.attachments) > 0}>
                <div class="text-xs font-medium text-slate-500 mb-1">ATTACHMENTS</div>
                <div class="flex items-center gap-2 text-sm text-slate-700">
                  <.icon name="hero-camera" class="w-4 h-4 text-slate-500" />
                  {length(request.attachments)} files
                </div>
              </div>
            </div>
            
    <!-- Admin Actions -->
            <div class="border-t border-slate-100 pt-4">
              <div class="flex items-center justify-between mb-3">
                <div class="text-xs font-medium text-slate-500 uppercase">Status Actions</div>
                <div class="text-xs font-medium text-slate-500 uppercase">Management</div>
              </div>

              <div class="flex items-center justify-between gap-4">
                <!-- Status Update Buttons -->
                <div class="flex gap-1">
                  <button
                    :if={request.status != "pending"}
                    phx-click="update_status"
                    phx-value-id={request.id}
                    phx-value-status="pending"
                    class="px-2 py-1 text-xs bg-slate-100 text-slate-700 rounded border hover:bg-slate-200 font-medium"
                  >
                    Pending
                  </button>
                  <button
                    :if={request.status != "in_progress"}
                    phx-click="update_status"
                    phx-value-id={request.id}
                    phx-value-status="in_progress"
                    class="px-2 py-1 text-xs bg-blue-100 text-blue-700 rounded border hover:bg-blue-200 font-medium"
                  >
                    In Progress
                  </button>
                  <button
                    :if={request.status != "completed"}
                    phx-click="update_status"
                    phx-value-id={request.id}
                    phx-value-status="completed"
                    class="px-2 py-1 text-xs bg-emerald-100 text-emerald-700 rounded border hover:bg-emerald-200 font-medium"
                  >
                    Complete
                  </button>
                </div>
                
    <!-- Management Buttons -->
                <div class="flex gap-1">
                  <.link
                    navigate={~p"/requests/#{request}"}
                    class="px-2 py-1 text-xs bg-slate-100 text-slate-700 rounded border hover:bg-slate-200 font-medium"
                  >
                    View
                  </.link>
                  <.link
                    navigate={~p"/triage/#{request}/edit"}
                    class="px-2 py-1 text-xs bg-blue-100 text-blue-700 rounded border hover:bg-blue-200 font-medium"
                  >
                    Edit
                  </.link>
                  <button
                    phx-click="delete_request"
                    phx-value-id={request.id}
                    data-confirm="Are you sure you want to delete this request? This action cannot be undone."
                    class="px-2 py-1 text-xs bg-red-100 text-red-700 rounded border hover:bg-red-200 font-medium"
                  >
                    Delete
                  </button>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    requests = Issues.list_requests()

    {:ok,
     socket
     |> assign(:page_title, "Issue Triage Dashboard")
     |> assign(:request_count, length(requests))
     |> stream(:requests, requests)}
  end

  @impl true
  def handle_event("update_status", %{"id" => id, "status" => status}, socket) do
    request = Issues.get_request!(id)

    case Issues.update_request(request, %{status: status}) do
      {:ok, updated_request} ->
        {:noreply,
         socket
         |> put_flash(:info, "Request status updated to #{status}")
         |> stream_insert(:requests, updated_request)}

      {:error, _changeset} ->
        {:noreply, put_flash(socket, :error, "Failed to update request status")}
    end
  end

  def handle_event("delete_request", %{"id" => id}, socket) do
    request = Issues.get_request!(id)

    case Issues.delete_request(request) do
      {:ok, _} ->
        {:noreply,
         socket
         |> put_flash(:info, "Request deleted successfully")
         |> assign(:request_count, socket.assigns.request_count - 1)
         |> stream_delete(:requests, request)}

      {:error, _changeset} ->
        {:noreply, put_flash(socket, :error, "Failed to delete request")}
    end
  end
end
