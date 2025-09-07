defmodule GearflowWeb.TriageLive.Show do
  use GearflowWeb, :live_view

  alias Gearflow.Issues

  @impl true
  def render(assigns) do
    ~H"""
    <div class="min-h-screen bg-slate-100 px-4 py-6">
      <!-- Admin Header Bar -->
      <div class="bg-slate-800 text-white px-6 py-3 mb-6 -mx-4">
        <div class="max-w-4xl mx-auto flex items-center justify-between">
          <div class="flex items-center gap-3">
            <.icon name="hero-cog-6-tooth" class="w-6 h-6 text-slate-300" />
            <span class="text-lg font-semibold">Admin Dashboard</span>
            <span class="text-sm text-slate-300">/ Triage Review</span>
          </div>
          <div class="flex items-center gap-4">
            <.link
              navigate={~p"/triage"}
              class="text-sm text-slate-300 hover:text-white"
            >
              ← Back to Triage
            </.link>
          </div>
        </div>
      </div>

      <div id="flash-messages" aria-live="polite" class="mb-4 max-w-4xl mx-auto">
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

      <div class="max-w-4xl mx-auto">
        <!-- Request Header Card -->
        <div class="bg-white rounded-lg shadow-md border-l-4 border-slate-600 p-6 mb-6">
          <div class="flex items-center justify-between mb-4">
            <div>
              <h1 class="text-2xl font-bold text-slate-900 mb-2">Request #{@request.id}</h1>
              <p class="text-slate-600">Triage Review and Management</p>
            </div>
            <%= if @request.needed_by do %>
              <div class="text-sm text-slate-500 text-right">
                <div class="text-xs font-medium text-slate-500 mb-1">DUE DATE</div>
                <div class="text-base font-semibold text-slate-700">
                  {Calendar.strftime(@request.needed_by, "%B %d, %Y")}
                </div>
              </div>
            <% end %>
          </div>
          
    <!-- Priority and Status Display -->
          <div class="flex items-center gap-6 mb-4">
            <div class="flex items-center gap-2">
              <span class="text-xs font-medium text-slate-500">PRIORITY</span>
              <div class={[
                "w-3 h-3 rounded-full",
                @request.priority == "urgent" && "bg-red-500 animate-pulse",
                @request.priority == "high" && "bg-orange-500",
                @request.priority == "medium" && "bg-yellow-500",
                @request.priority == "low" && "bg-green-500"
              ]}>
              </div>
              <span class={[
                "px-2 py-1 text-xs font-bold rounded border",
                @request.priority == "urgent" && "bg-red-50 text-red-700 border-red-200",
                @request.priority == "high" && "bg-orange-50 text-orange-700 border-orange-200",
                @request.priority == "medium" && "bg-yellow-50 text-yellow-700 border-yellow-200",
                @request.priority == "low" && "bg-green-50 text-green-700 border-green-200"
              ]}>
                {String.upcase(@request.priority || "MEDIUM")}
              </span>
            </div>

            <div class="flex items-center gap-2">
              <span class="text-xs font-medium text-slate-500">STATUS</span>
              <span class={[
                "px-2 py-1 text-xs font-bold rounded border",
                @request.status == "pending" && "bg-slate-50 text-slate-700 border-slate-200",
                @request.status == "in_progress" && "bg-blue-50 text-blue-700 border-blue-200",
                @request.status == "completed" && "bg-emerald-50 text-emerald-700 border-emerald-200"
              ]}>
                {String.upcase(@request.status || "PENDING")}
              </span>
            </div>
          </div>
        </div>
        
    <!-- Request Details Card -->
        <div class="bg-white rounded-lg shadow-md border border-slate-200 p-6 mb-6">
          <h2 class="text-lg font-semibold text-slate-900 mb-4">Request Details</h2>
          
    <!-- Description -->
          <div class="mb-6">
            <h3 class="text-base font-medium text-slate-900 mb-2">Description</h3>
            <div class="p-4 bg-slate-50 rounded-lg border text-slate-700 leading-relaxed">
              {@request.description}
            </div>
          </div>
          
    <!-- Equipment Info -->
          <%= if @request.equipment_id && @request.equipment_id != "" do %>
            <div class="mb-6">
              <h3 class="text-base font-medium text-slate-900 mb-2">Equipment/Unit</h3>
              <div class="flex items-center gap-3 p-4 bg-slate-50 rounded-lg border">
                <.icon name="hero-wrench-screwdriver" class="w-5 h-5 text-slate-500" />
                <span class="text-slate-700 font-mono">{@request.equipment_id}</span>
              </div>
            </div>
          <% end %>
          
    <!-- Attachments -->
          <%= if @request.attachments && length(@request.attachments) > 0 do %>
            <div class="mb-6">
              <h3 class="text-base font-medium text-slate-900 mb-3">
                Attachments ({length(@request.attachments)} {if length(@request.attachments) == 1,
                  do: "attachment",
                  else: "attachments"})
              </h3>

              <%= for {attachment, index} <- Enum.with_index(@request.attachments) do %>
                <%= if is_image?(attachment) do %>
                  <!-- Image Preview -->
                  <div class="mb-4">
                    <div class="flex items-center justify-between mb-2">
                      <div class="flex items-center gap-2">
                        <.icon name="hero-photo" class="w-4 h-4 text-green-500" />
                        <span class="text-sm text-slate-700 font-medium">
                          {Path.basename(attachment)}
                        </span>
                      </div>
                      <button
                        type="button"
                        phx-click="toggle_image"
                        phx-value-index={index}
                        class="text-xs text-slate-600 hover:text-slate-800 px-2 py-1 rounded hover:bg-slate-100"
                      >
                        {if Map.get(@expanded_images, index, false), do: "Hide", else: "Show"}
                      </button>
                    </div>

                    <%= if Map.get(@expanded_images, index, false) do %>
                      <div class="border border-slate-200 rounded-lg overflow-hidden bg-slate-50">
                        <img
                          src={attachment}
                          alt={Path.basename(attachment)}
                          class="max-w-full h-auto max-h-96 mx-auto block"
                          style="object-fit: contain;"
                        />
                      </div>
                    <% end %>
                  </div>
                <% else %>
                  <!-- Non-image file -->
                  <div class="flex items-center justify-between p-3 bg-slate-50 rounded-lg border mb-3">
                    <div class="flex items-center space-x-3">
                      <%= if String.contains?(attachment, "voice_memo") do %>
                        <.icon name="hero-microphone" class="w-5 h-5 text-red-500" />
                        <span class="text-sm text-slate-700">Voice Memo</span>
                      <% else %>
                        <%= if String.contains?(attachment, ".mp4") || String.contains?(attachment, ".mov") || String.contains?(attachment, ".webm") do %>
                          <.icon name="hero-video-camera" class="w-5 h-5 text-blue-500" />
                          <span class="text-sm text-slate-700">Video</span>
                        <% else %>
                          <.icon name="hero-document" class="w-5 h-5 text-slate-500" />
                          <span class="text-sm text-slate-700">File</span>
                        <% end %>
                      <% end %>
                      <span class="text-xs text-slate-500 font-mono">
                        {Path.basename(attachment)}
                      </span>
                    </div>
                    <button
                      type="button"
                      phx-click="view_attachment"
                      phx-value-index={index}
                      class="text-xs text-slate-600 hover:text-slate-800 px-2 py-1 rounded hover:bg-slate-100"
                    >
                      View
                    </button>
                  </div>
                <% end %>
              <% end %>
            </div>
          <% end %>
          
    <!-- Timestamps -->
          <div class="mt-6 grid grid-cols-1 md:grid-cols-2 gap-4 p-3 bg-slate-50 rounded border">
            <div>
              <div class="text-xs font-medium text-slate-500 mb-1">CREATED</div>
              <div class="text-sm text-slate-700">
                {Calendar.strftime(@request.inserted_at, "%B %d, %Y at %I:%M %p")}
              </div>
            </div>
            <div>
              <div class="text-xs font-medium text-slate-500 mb-1">LAST UPDATED</div>
              <div class="text-sm text-slate-700">
                {Calendar.strftime(@request.updated_at, "%B %d, %Y at %I:%M %p")}
              </div>
            </div>
          </div>
        </div>
        
    <!-- Quick Action Panel -->
        <div class="bg-white rounded-lg shadow-md border border-slate-200 p-6 mb-6">
          <h2 class="text-lg font-semibold text-slate-900 mb-4">Quick Actions</h2>

          <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
            <!-- Status Actions -->
            <div>
              <h3 class="text-sm font-medium text-slate-700 mb-3">Change Status</h3>
              <div class="flex gap-2 flex-wrap">
                <button
                  :if={@request.status != "pending"}
                  phx-click="update_status"
                  phx-value-status="pending"
                  class="px-4 py-2 text-sm bg-slate-600 text-white rounded-lg hover:bg-slate-700 font-medium shadow-sm transition-colors"
                >
                  ← Mark Pending
                </button>
                <button
                  :if={@request.status != "in_progress"}
                  phx-click="update_status"
                  phx-value-status="in_progress"
                  class="px-4 py-2 text-sm bg-blue-600 text-white rounded-lg hover:bg-blue-700 font-medium shadow-sm transition-colors"
                >
                  🚀 Start Work
                </button>
                <button
                  :if={@request.status != "completed"}
                  phx-click="update_status"
                  phx-value-status="completed"
                  class="px-4 py-2 text-sm bg-emerald-600 text-white rounded-lg hover:bg-emerald-700 font-medium shadow-sm transition-colors"
                >
                  ✅ Mark Complete
                </button>
              </div>
            </div>
            
    <!-- Priority Actions -->
            <div>
              <h3 class="text-sm font-medium text-slate-700 mb-3">Assign Priority</h3>
              <div class="flex gap-2 flex-wrap">
                <button
                  :if={@request.priority != "urgent"}
                  phx-click="update_priority"
                  phx-value-priority="urgent"
                  class="px-3 py-2 text-xs bg-red-100 text-red-700 rounded-lg border hover:bg-red-200 font-medium"
                >
                  🚨 Urgent
                </button>
                <button
                  :if={@request.priority != "high"}
                  phx-click="update_priority"
                  phx-value-priority="high"
                  class="px-3 py-2 text-xs bg-orange-100 text-orange-700 rounded-lg border hover:bg-orange-200 font-medium"
                >
                  ⚠️ High
                </button>
                <button
                  :if={@request.priority != "medium"}
                  phx-click="update_priority"
                  phx-value-priority="medium"
                  class="px-3 py-2 text-xs bg-yellow-100 text-yellow-700 rounded-lg border hover:bg-yellow-200 font-medium"
                >
                  ⏰ Medium
                </button>
                <button
                  :if={@request.priority != "low"}
                  phx-click="update_priority"
                  phx-value-priority="low"
                  class="px-3 py-2 text-xs bg-green-100 text-green-700 rounded-lg border hover:bg-green-200 font-medium"
                >
                  📋 Low
                </button>
              </div>
            </div>
          </div>

          <div class="border-t border-slate-100 mt-6 pt-4">
            <div class="flex gap-3">
              <.link
                navigate={~p"/triage/#{@request}/edit"}
                class="px-4 py-2 bg-slate-600 text-white rounded-lg hover:bg-slate-700 font-medium"
              >
                Edit Request
              </.link>
              <button
                type="button"
                phx-click="add_notes"
                class="px-4 py-2 bg-blue-100 text-blue-700 rounded-lg border border-blue-200 hover:bg-blue-200 font-medium"
              >
                Add Notes
              </button>
            </div>
          </div>
        </div>
      </div>
    </div>
    """
  end

  @impl true
  def mount(%{"id" => id}, _session, socket) do
    request = Issues.get_request!(id)

    {:ok,
     socket
     |> assign(:page_title, "Triage Review - Request #{id}")
     |> assign(:request, request)
     |> assign(:expanded_images, %{})}
  end

  @impl true
  def handle_event("update_status", %{"status" => status}, socket) do
    case Issues.update_request(socket.assigns.request, %{status: status}) do
      {:ok, updated_request} ->
        {:noreply,
         socket
         |> put_flash(:info, "Status updated to #{status}")
         |> assign(:request, updated_request)}

      {:error, _changeset} ->
        {:noreply, put_flash(socket, :error, "Failed to update status")}
    end
  end

  def handle_event("update_priority", %{"priority" => priority}, socket) do
    case Issues.update_request(socket.assigns.request, %{priority: priority}) do
      {:ok, updated_request} ->
        {:noreply,
         socket
         |> put_flash(:info, "Priority updated to #{priority}")
         |> assign(:request, updated_request)}

      {:error, _changeset} ->
        {:noreply, put_flash(socket, :error, "Failed to update priority")}
    end
  end

  def handle_event("add_notes", _params, socket) do
    # TODO: Implement notes functionality
    {:noreply, put_flash(socket, :info, "Notes functionality coming soon")}
  end

  def handle_event("toggle_image", %{"index" => index}, socket) do
    index = String.to_integer(index)
    expanded_images = socket.assigns.expanded_images

    updated_images =
      if Map.get(expanded_images, index, false) do
        Map.delete(expanded_images, index)
      else
        Map.put(expanded_images, index, true)
      end

    {:noreply, assign(socket, :expanded_images, updated_images)}
  end

  def handle_event("view_attachment", %{"index" => _index}, socket) do
    # TODO: Implement attachment viewing
    {:noreply, put_flash(socket, :info, "Attachment viewing functionality coming soon")}
  end

  # Helper function to check if a file is an image
  defp is_image?(file_path) do
    file_path
    |> String.downcase()
    |> String.ends_with?([".jpg", ".jpeg", ".png", ".gif", ".webp", ".bmp"])
  end
end
