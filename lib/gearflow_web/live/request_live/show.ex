defmodule GearflowWeb.RequestLive.Show do
  use GearflowWeb, :live_view

  alias Gearflow.Issues

  @impl true
  def render(assigns) do
    ~H"""
    <div class="min-h-screen bg-gray-50 px-4 py-6">
      <div id="flash-messages" aria-live="polite" class="mb-4">
        <%= if Phoenix.Flash.get(@flash, :info) do %>
          <div
            class="bg-green-100 border border-green-400 text-green-700 px-4 py-3 rounded-lg mb-4"
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
              <div class={[
                "inline-flex items-center px-3 py-1 rounded-full text-sm font-medium",
                case @request.priority do
                  "urgent" -> "bg-red-100 text-red-800"
                  "high" -> "bg-orange-100 text-orange-800"
                  "medium" -> "bg-yellow-100 text-yellow-800"
                  "low" -> "bg-green-100 text-green-800"
                  _ -> "bg-gray-100 text-gray-800"
                end
              ]}>
                {case @request.priority do
                  "urgent" -> "🚨 URGENT"
                  "high" -> "⚠️ HIGH"
                  "medium" -> "⏰ NORMAL"
                  "low" -> "📋 LOW"
                  _ -> String.upcase(@request.priority || "")
                end}
              </div>
            </div>

            <div>
              <label class="block text-sm font-medium text-gray-700 mb-2">Status</label>
              <div class={[
                "inline-flex items-center px-3 py-1 rounded-full text-sm font-medium",
                case @request.status do
                  "pending" -> "bg-yellow-100 text-yellow-800"
                  "in_progress" -> "bg-blue-100 text-blue-800"
                  "completed" -> "bg-green-100 text-green-800"
                  _ -> "bg-gray-100 text-gray-800"
                end
              ]}>
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
                  <%= for {attachment, index} <- Enum.with_index(@request.attachments) do %>
                    <div class="flex items-center justify-between p-3 bg-gray-50 rounded-lg">
                      <div class="flex items-center space-x-3">
                        <%= if String.contains?(attachment, "voice_memo") do %>
                          <.icon name="hero-microphone" class="w-5 h-5 text-red-500" />
                          <span class="text-sm text-gray-700">Voice Memo</span>
                        <% else %>
                          <%= if String.contains?(attachment, ".mp4") || String.contains?(attachment, ".mov") do %>
                            <.icon name="hero-video-camera" class="w-5 h-5 text-blue-500" />
                            <span class="text-sm text-gray-700">Video File</span>
                          <% else %>
                            <.icon name="hero-photo" class="w-5 h-5 text-green-500" />
                            <span class="text-sm text-gray-700">Image File</span>
                          <% end %>
                        <% end %>
                      </div>
                      <button
                        type="button"
                        phx-click="show-attachment"
                        phx-value-index={index}
                        class="text-sm text-blue-600 hover:text-blue-800 px-3 py-1 rounded hover:bg-blue-50"
                      >
                        View Details
                      </button>
                    </div>
                  <% end %>
                </div>
              </div>
            <% end %>

            <%= if @show_attachment_modal do %>
              <div
                class="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50"
                phx-click="close-modal"
              >
                <div class="bg-white rounded-lg p-6 max-w-sm mx-4" phx-click-away="close-modal">
                  <div class="flex items-center justify-between mb-4">
                    <h3 class="text-lg font-semibold text-gray-900">Attachment Details</h3>
                    <button
                      type="button"
                      phx-click="close-modal"
                      class="text-gray-400 hover:text-gray-600"
                    >
                      <.icon name="hero-x-mark" class="w-5 h-5" />
                    </button>
                  </div>

                  <div class="space-y-3">
                    <div>
                      <label class="block text-sm font-medium text-gray-700">File Name</label>
                      <p class="text-sm text-gray-900 bg-gray-50 p-2 rounded mt-1">
                        {Path.basename(@selected_attachment || "")}
                      </p>
                    </div>

                    <div>
                      <label class="block text-sm font-medium text-gray-700">File Type</label>
                      <p class="text-sm text-gray-900 bg-gray-50 p-2 rounded mt-1">
                        {cond do
                          String.contains?(@selected_attachment || "", "voice_memo") ->
                            "Voice Memo (WebM Audio)"

                          String.contains?(@selected_attachment || "", ".mp4") ->
                            "MP4 Video"

                          String.contains?(@selected_attachment || "", ".mov") ->
                            "MOV Video"

                          String.contains?(@selected_attachment || "", ".webm") ->
                            "WebM Video"

                          true ->
                            "Image File"
                        end}
                      </p>
                    </div>

                    <div>
                      <label class="block text-sm font-medium text-gray-700">File Path</label>
                      <p class="text-sm text-gray-900 bg-gray-50 p-2 rounded mt-1 font-mono break-all">
                        {@selected_attachment}
                      </p>
                    </div>

                    <div class="bg-yellow-50 border border-yellow-200 rounded-lg p-3">
                      <div class="flex">
                        <.icon
                          name="hero-exclamation-triangle"
                          class="w-5 h-5 text-yellow-400 mr-2 mt-0.5"
                        />
                        <div>
                          <h4 class="text-sm font-medium text-yellow-800">TODO</h4>
                          <p class="text-sm text-yellow-700 mt-1">
                            File viewing functionality needs to be implemented. This will require proper file serving and content type handling.
                          </p>
                        </div>
                      </div>
                    </div>
                  </div>

                  <div class="mt-6">
                    <button
                      type="button"
                      phx-click="close-modal"
                      class="w-full py-2 px-4 bg-gray-100 text-gray-700 rounded-lg hover:bg-gray-200"
                    >
                      Close
                    </button>
                  </div>
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
     |> assign(:request, Issues.get_request!(id))
     |> assign(:show_attachment_modal, false)
     |> assign(:selected_attachment, nil)}
  end

  @impl true
  def handle_event("show-attachment", %{"index" => index}, socket) do
    index = String.to_integer(index)
    attachment = Enum.at(socket.assigns.request.attachments, index)

    {:noreply,
     socket
     |> assign(:show_attachment_modal, true)
     |> assign(:selected_attachment, attachment)}
  end

  def handle_event("close-modal", _params, socket) do
    {:noreply,
     socket
     |> assign(:show_attachment_modal, false)
     |> assign(:selected_attachment, nil)}
  end
end
