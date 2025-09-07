defmodule GearflowWeb.TriageLive.Edit do
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
            <span class="text-sm text-slate-300">/ Triage Edit</span>
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
        <div class="bg-white rounded-lg shadow-md border-l-4 border-slate-600 p-6 mb-6">
          <div class="flex items-center justify-between mb-4">
            <div>
              <h1 class="text-2xl font-bold text-slate-900 mb-2">Edit Request #{@request.id}</h1>
              <p class="text-slate-600">Administrative editing interface</p>
            </div>
            <div class="text-sm text-slate-500">
              <div>Created: {Calendar.strftime(@request.inserted_at, "%m/%d/%y %I:%M %p")}</div>
              <div>Updated: {Calendar.strftime(@request.updated_at, "%m/%d/%y %I:%M %p")}</div>
            </div>
          </div>
        </div>

        <.form
          for={@form}
          id="triage-edit-form"
          phx-change="validate"
          phx-submit="save"
          class="space-y-6"
        >
          <div class="bg-white rounded-lg shadow-md border border-slate-200 p-6">
            <h2 class="text-lg font-semibold text-slate-900 mb-4">Request Details</h2>

            <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
              <!-- Status -->
              <div>
                <label class="block text-sm font-medium text-slate-700 mb-3">
                  Status <span class="text-red-500">*</span>
                </label>
                <div class="space-y-2">
                  <label class="flex items-center">
                    <input
                      type="radio"
                      name={@form[:status].name}
                      value="pending"
                      checked={@form[:status].value == "pending"}
                      class="mr-3 text-slate-600"
                    />
                    <span class="px-2 py-1 text-xs bg-slate-100 text-slate-700 rounded border font-medium">
                      PENDING
                    </span>
                  </label>
                  <label class="flex items-center">
                    <input
                      type="radio"
                      name={@form[:status].name}
                      value="in_progress"
                      checked={@form[:status].value == "in_progress"}
                      class="mr-3 text-blue-600"
                    />
                    <span class="px-2 py-1 text-xs bg-blue-100 text-blue-700 rounded border font-medium">
                      IN PROGRESS
                    </span>
                  </label>
                  <label class="flex items-center">
                    <input
                      type="radio"
                      name={@form[:status].name}
                      value="completed"
                      checked={@form[:status].value == "completed"}
                      class="mr-3 text-emerald-600"
                    />
                    <span class="px-2 py-1 text-xs bg-emerald-100 text-emerald-700 rounded border font-medium">
                      COMPLETED
                    </span>
                  </label>
                </div>
              </div>
              
    <!-- Priority -->
              <div>
                <label class="block text-sm font-medium text-slate-700 mb-3">
                  Priority <span class="text-red-500">*</span>
                </label>
                <div class="space-y-2">
                  <label class="flex items-center">
                    <input
                      type="radio"
                      name={@form[:priority].name}
                      value="urgent"
                      checked={@form[:priority].value == "urgent"}
                      class="mr-3 text-red-600"
                    />
                    <span class="px-2 py-1 text-xs bg-red-100 text-red-700 rounded border font-medium">
                      🚨 URGENT
                    </span>
                  </label>
                  <label class="flex items-center">
                    <input
                      type="radio"
                      name={@form[:priority].name}
                      value="high"
                      checked={@form[:priority].value == "high"}
                      class="mr-3 text-orange-600"
                    />
                    <span class="px-2 py-1 text-xs bg-orange-100 text-orange-700 rounded border font-medium">
                      ⚠️ HIGH
                    </span>
                  </label>
                  <label class="flex items-center">
                    <input
                      type="radio"
                      name={@form[:priority].name}
                      value="medium"
                      checked={@form[:priority].value == "medium"}
                      class="mr-3 text-yellow-600"
                    />
                    <span class="px-2 py-1 text-xs bg-yellow-100 text-yellow-700 rounded border font-medium">
                      ⏰ MEDIUM
                    </span>
                  </label>
                  <label class="flex items-center">
                    <input
                      type="radio"
                      name={@form[:priority].name}
                      value="low"
                      checked={@form[:priority].value == "low"}
                      class="mr-3 text-green-600"
                    />
                    <span class="px-2 py-1 text-xs bg-green-100 text-green-700 rounded border font-medium">
                      📋 LOW
                    </span>
                  </label>
                </div>
              </div>
              
    <!-- Equipment ID -->
              <div>
                <label class="block text-sm font-medium text-slate-700 mb-2">
                  Equipment/Unit Number
                </label>
                <.input
                  field={@form[:equipment_id]}
                  type="text"
                  placeholder="e.g. CAT D7, Unit 21784"
                  class="text-base w-full bg-white border-slate-300 text-slate-900 placeholder-slate-500 focus:border-slate-500 focus:ring-slate-500"
                />
              </div>
              
    <!-- Needed By -->
              <div>
                <label class="block text-sm font-medium text-slate-700 mb-2">
                  Needed By
                </label>
                <.input
                  field={@form[:needed_by]}
                  type="date"
                  class="text-base w-full bg-white border-slate-300 text-slate-900 focus:border-slate-500 focus:ring-slate-500"
                />
              </div>
            </div>
            
    <!-- Description -->
            <div class="mt-6">
              <label class="block text-sm font-medium text-slate-700 mb-2">
                Description <span class="text-red-500">*</span>
              </label>
              <.input
                field={@form[:description]}
                type="textarea"
                placeholder="Describe the issue or request in detail..."
                class="text-base min-h-[120px] w-full bg-white border-slate-300 text-slate-900 placeholder-slate-500 focus:border-slate-500 focus:ring-slate-500"
              />
            </div>
            
    <!-- Attachments Display -->
            <%= if @request.attachments && length(@request.attachments) > 0 do %>
              <div class="mt-6">
                <label class="block text-sm font-medium text-slate-700 mb-3">
                  Current Attachments
                </label>
                <div class="grid grid-cols-1 md:grid-cols-2 gap-3">
                  <%= for {attachment, index} <- Enum.with_index(@request.attachments) do %>
                    <div class="flex items-center justify-between p-3 bg-slate-50 rounded border">
                      <div class="flex items-center space-x-3">
                        <%= if String.contains?(attachment, "voice_memo") do %>
                          <.icon name="hero-microphone" class="w-5 h-5 text-red-500" />
                          <span class="text-sm text-slate-700">Voice Memo</span>
                        <% else %>
                          <%= if String.contains?(attachment, ".mp4") || String.contains?(attachment, ".mov") do %>
                            <.icon name="hero-video-camera" class="w-5 h-5 text-blue-500" />
                            <span class="text-sm text-slate-700">Video</span>
                          <% else %>
                            <.icon name="hero-photo" class="w-5 h-5 text-green-500" />
                            <span class="text-sm text-slate-700">Image</span>
                          <% end %>
                        <% end %>
                        <span class="text-xs text-slate-500 font-mono">
                          {Path.basename(attachment)}
                        </span>
                      </div>
                    </div>
                  <% end %>
                </div>
              </div>
            <% end %>
          </div>
          
    <!-- Admin Actions -->
          <div class="bg-white rounded-lg shadow-md border border-slate-200 p-6">
            <div class="flex items-center justify-center gap-4">
              <.button
                type="submit"
                phx-disable-with="Saving..."
                class="px-6 py-2 bg-slate-600 text-white font-medium rounded-lg hover:bg-slate-700"
              >
                Save Changes
              </.button>
              <.link
                navigate={~p"/triage"}
                class="flex items-center px-6 py-2 bg-slate-200 text-slate-700 font-medium rounded-lg hover:bg-slate-300"
              >
                Cancel
              </.link>
              <button
                type="button"
                phx-click="delete_request"
                data-confirm="Are you sure you want to delete this request? This action cannot be undone."
                class="px-6 py-2 bg-red-100 text-red-700 rounded-lg hover:bg-red-200 font-medium border border-red-200"
              >
                Delete Request
              </button>
            </div>
          </div>
        </.form>
      </div>
    </div>
    """
  end

  @impl true
  def mount(%{"id" => id}, _session, socket) do
    request = Issues.get_request!(id)

    {:ok,
     socket
     |> assign(:page_title, "Edit Request #{id}")
     |> assign(:request, request)
     |> assign(:form, to_form(Issues.change_request(request)))}
  end

  @impl true
  def handle_event("validate", %{"request" => request_params}, socket) do
    changeset = Issues.change_request(socket.assigns.request, request_params)
    {:noreply, assign(socket, form: to_form(changeset, action: :validate))}
  end

  def handle_event("save", %{"request" => request_params}, socket) do
    case Issues.update_request(socket.assigns.request, request_params) do
      {:ok, request} ->
        {:noreply,
         socket
         |> put_flash(:info, "Request updated successfully")
         |> assign(:request, request)
         |> push_navigate(to: ~p"/triage")}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  def handle_event("delete_request", _params, socket) do
    case Issues.delete_request(socket.assigns.request) do
      {:ok, _} ->
        {:noreply,
         socket
         |> put_flash(:info, "Request deleted successfully")
         |> push_navigate(to: ~p"/triage")}

      {:error, _changeset} ->
        {:noreply, put_flash(socket, :error, "Failed to delete request")}
    end
  end
end
