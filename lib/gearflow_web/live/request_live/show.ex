defmodule GearflowWeb.RequestLive.Show do
  use GearflowWeb, :live_view

  alias Gearflow.Issues

  @impl true
  def render(assigns) do
    ~H"""
    <div class="min-h-screen bg-gray-50 px-4 py-6">
      <div class="max-w-lg mx-auto">
        <div class="bg-white rounded-lg shadow-sm p-6 mb-6">
          <div class="flex items-center justify-between mb-4">
            <h1 class="text-xl font-bold text-gray-900">Request {@request.id}</h1>
            <.link navigate={~p"/requests"} class="text-blue-600 text-sm font-medium">
              ← Back to Dashboard
            </.link>
          </div>
        </div>

        <div class="bg-white rounded-lg shadow-sm p-6 mb-6">
          <h2 class="text-lg font-semibold text-gray-900 mb-4">Request Details</h2>
          
          <div class="space-y-4">
            <%= if @request.description && @request.description != "" do %>
              <div>
                <label class="block text-sm font-medium text-gray-700 mb-2">Description</label>
                <div class="p-3 bg-gray-50 rounded-lg text-gray-900">
                  {@request.description}
                </div>
              </div>
            <% end %>

            <div>
              <label class="block text-sm font-medium text-gray-700 mb-2">Priority</label>
              <div class={["inline-flex items-center px-3 py-1 rounded-full text-sm font-medium",
                case @request.priority do
                  "urgent" -> "bg-red-100 text-red-800"
                  "high" -> "bg-orange-100 text-orange-800"  
                  "medium" -> "bg-yellow-100 text-yellow-800"
                  "low" -> "bg-green-100 text-green-800"
                  _ -> "bg-gray-100 text-gray-800"
                end]}>
                <%= case @request.priority do
                  "urgent" -> "🚨 URGENT"
                  "high" -> "⚠️ HIGH"
                  "medium" -> "⏰ NORMAL"
                  "low" -> "📋 LOW"
                  _ -> String.upcase(@request.priority || "")
                end %>
              </div>
            </div>

            <div>
              <label class="block text-sm font-medium text-gray-700 mb-2">Status</label>
              <div class={["inline-flex items-center px-3 py-1 rounded-full text-sm font-medium",
                case @request.status do
                  "pending" -> "bg-yellow-100 text-yellow-800"
                  "in_progress" -> "bg-blue-100 text-blue-800"
                  "completed" -> "bg-green-100 text-green-800"
                  _ -> "bg-gray-100 text-gray-800"
                end]}>
                {String.upcase(@request.status || "")}
              </div>
            </div>

            <%= if @request.equipment_id && @request.equipment_id != "" do %>
              <div>
                <label class="block text-sm font-medium text-gray-700 mb-2">Equipment/Unit</label>
                <div class="p-3 bg-gray-50 rounded-lg text-gray-900 font-mono">
                  {@request.equipment_id}
                </div>
              </div>
            <% end %>

            <%= if @request.needed_by do %>
              <div>
                <label class="block text-sm font-medium text-gray-700 mb-2">Needed By</label>
                <div class="p-3 bg-gray-50 rounded-lg text-gray-900">
                  {Calendar.strftime(@request.needed_by, "%B %d, %Y")}
                </div>
              </div>
            <% end %>

            <%= if @request.attachments && length(@request.attachments) > 0 do %>
              <div>
                <label class="block text-sm font-medium text-gray-700 mb-2">Attachments</label>
                <div class="space-y-2">
                  <%= for attachment <- @request.attachments do %>
                    <div class="flex items-center space-x-3 p-3 bg-gray-50 rounded-lg">
                      <%= if String.contains?(attachment, "voice_memo") do %>
                        <.icon name="hero-microphone" class="w-5 h-5 text-red-500" />
                        <span class="text-sm text-gray-700">Voice Memo</span>
                      <% else %>
                        <%= if String.contains?(attachment, ".mp4") || String.contains?(attachment, ".mov") do %>
                          <.icon name="hero-video-camera" class="w-5 h-5 text-blue-500" />
                        <% else %>
                          <.icon name="hero-photo" class="w-5 h-5 text-green-500" />
                        <% end %>
                      <% end %>
                      <a href={attachment} target="_blank" class="text-sm text-blue-600 hover:text-blue-800 underline">
                        View File
                      </a>
                    </div>
                  <% end %>
                </div>
              </div>
            <% end %>
          </div>
        </div>

        <div class="flex gap-3">
          <.button 
            navigate={~p"/requests/#{@request}/edit?return_to=show"}
            class="flex-1 py-3 text-base font-medium bg-blue-600 text-white rounded-lg hover:bg-blue-700 touch-manipulation text-center"
          >
            Edit Request
          </.button>
        </div>
      </div>
    </div>
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
