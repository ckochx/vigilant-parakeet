defmodule GearflowWeb.RequestLive.Form do
  use GearflowWeb, :live_view

  alias Gearflow.Issues
  alias Gearflow.Issues.Request

  @impl true
  def render(assigns) do
    ~H"""
    <div class="min-h-screen bg-gray-50 px-4 py-6">
      <div class="max-w-lg mx-auto">
        <div class="bg-white rounded-lg shadow-sm p-6 mb-6">
          <div class="flex items-center justify-between mb-4">
            <h1 class="text-xl font-bold text-gray-900">{@page_title}</h1>
            <.link navigate={~p"/requests"} class="text-blue-600 text-sm font-medium">
              ← Back to Dashboard
            </.link>
          </div>
        </div>

        <.form
          for={@form}
          id="request-form"
          phx-change="validate"
          phx-submit="save"
          phx-hook="SpeechRecognition"
          class="space-y-6"
        >
          <div class="bg-white rounded-lg shadow-sm p-6">
            <h2 class="text-lg font-semibold text-gray-900 mb-4">What's the issue?</h2>

            <div class="space-y-4">
              <div>
                <div class="mb-2">
                  <label class="block text-sm font-medium text-gray-700 mb-3">
                    Describe the problem or request
                  </label>
                  <div class="flex flex-col sm:flex-row gap-3 mb-3">
                    <button
                      type="button"
                      phx-click="start-speech-recognition"
                      class="flex-1 sm:flex-none px-4 py-3 bg-blue-100 text-blue-700 rounded-lg hover:bg-blue-200 touch-manipulation"
                      title="Speech to text"
                    >
                      🎤 Speech to Text
                    </button>
                    <button
                      type="button"
                      phx-click="start-voice-recording"
                      class="flex-1 sm:flex-none px-4 py-3 bg-red-100 text-red-700 rounded-lg hover:bg-red-200 touch-manipulation"
                      title="Record voice memo"
                    >
                      🎙️ Record Voice Memo
                    </button>
                  </div>
                </div>
                <.input
                  field={@form[:description]}
                  type="textarea"
                  placeholder="Example: Final drive failure on digger unit 21784"
                  class="text-base min-h-[120px] w-full textarea bg-white border-gray-300 text-gray-900 placeholder-gray-500 focus:border-blue-500 focus:ring-blue-500"
                />
              </div>

              <div>
                <label class="block text-sm font-medium text-gray-700 mb-3">
                  How urgent is this?
                </label>
                <div class="grid grid-cols-2 gap-3">
                  <label class="relative">
                    <input
                      type="radio"
                      name={@form[:priority].name}
                      value="urgent"
                      checked={@form[:priority].value == "urgent"}
                      class="sr-only peer"
                    />
                    <div class="p-4 border-2 border-gray-200 rounded-lg peer-checked:border-red-500 peer-checked:bg-red-50 cursor-pointer touch-manipulation">
                      <div class="text-center">
                        <div class="text-2xl mb-1">🚨</div>
                        <div class="text-sm font-medium text-gray-900">URGENT</div>
                        <div class="text-xs text-gray-500">Machine down</div>
                      </div>
                    </div>
                  </label>

                  <label class="relative">
                    <input
                      type="radio"
                      name={@form[:priority].name}
                      value="high"
                      checked={@form[:priority].value == "high"}
                      class="sr-only peer"
                    />
                    <div class="p-4 border-2 border-gray-200 rounded-lg peer-checked:border-orange-500 peer-checked:bg-orange-50 cursor-pointer touch-manipulation">
                      <div class="text-center">
                        <div class="text-2xl mb-1">⚠️</div>
                        <div class="text-sm font-medium text-gray-900">HIGH</div>
                        <div class="text-xs text-gray-500">Soon</div>
                      </div>
                    </div>
                  </label>

                  <label class="relative">
                    <input
                      type="radio"
                      name={@form[:priority].name}
                      value="medium"
                      checked={@form[:priority].value == "medium" || is_nil(@form[:priority].value)}
                      class="sr-only peer"
                    />
                    <div class="p-4 border-2 border-gray-200 rounded-lg peer-checked:border-yellow-500 peer-checked:bg-yellow-50 cursor-pointer touch-manipulation">
                      <div class="text-center">
                        <div class="text-2xl mb-1">⏰</div>
                        <div class="text-sm font-medium text-gray-900">NORMAL</div>
                        <div class="text-xs text-gray-500">This week</div>
                      </div>
                    </div>
                  </label>

                  <label class="relative">
                    <input
                      type="radio"
                      name={@form[:priority].name}
                      value="low"
                      checked={@form[:priority].value == "low"}
                      class="sr-only peer"
                    />
                    <div class="p-4 border-2 border-gray-200 rounded-lg peer-checked:border-green-500 peer-checked:bg-green-50 cursor-pointer touch-manipulation">
                      <div class="text-center">
                        <div class="text-2xl mb-1">📋</div>
                        <div class="text-sm font-medium text-gray-900">LOW</div>
                        <div class="text-xs text-gray-500">When convenient</div>
                      </div>
                    </div>
                  </label>
                </div>
              </div>

              <div>
                <label class="block text-sm font-medium text-gray-700 mb-2">
                  Equipment/Unit Number (if applicable)
                </label>
                <.input
                  field={@form[:equipment_id]}
                  type="text"
                  placeholder="e.g. CAT D7, Unit 21784"
                  class="text-base w-full input bg-white border-gray-300 text-gray-900 placeholder-gray-500 focus:border-blue-500 focus:ring-blue-500"
                />
              </div>

              <div>
                <label 
                  for="request_needed_by"
                  class="block text-sm font-medium text-gray-700 mb-2 cursor-pointer"
                >
                  When do you need this by? (optional)
                </label>
                <div class="relative">
                  <.input
                    field={@form[:needed_by]}
                    type="date"
                    class="text-base w-full input bg-white border-gray-300 text-gray-900 focus:border-blue-500 focus:ring-blue-500"
                  />
                  <div 
                    class="absolute inset-0 cursor-pointer"
                    onclick="document.getElementById('request_needed_by').showPicker()"
                  >
                  </div>
                </div>
              </div>
            </div>
          </div>

          <div class="bg-white rounded-lg shadow-sm p-6">
            <h3 class="text-lg font-semibold text-gray-900 mb-4">Add Photos & Videos</h3>
            <div
              class="border-2 border-dashed border-gray-300 rounded-lg p-8 text-center"
              phx-drop-target={@uploads.attachments.ref}
            >
              <div class="text-4xl mb-2">📸</div>
              <p class="text-sm text-gray-600 mb-4">
                Take photos or videos to help explain the issue
              </p>
              <label
                for={@uploads.attachments.ref}
                class="inline-flex items-center px-4 py-2 bg-blue-600 text-white rounded-lg hover:bg-blue-700 cursor-pointer touch-manipulation"
              >
                <.icon name="hero-camera" class="w-5 h-5 mr-2" /> Add Photos & Videos
                <.live_file_input upload={@uploads.attachments} class="hidden" />
              </label>
            </div>

            <%= for entry <- @uploads.attachments.entries do %>
              <div class="flex items-center justify-between p-3 bg-gray-50 rounded-lg mt-3">
                <div class="flex items-center space-x-3">
                  <%= if String.contains?(entry.client_type, "video") do %>
                    <.icon name="hero-video-camera" class="w-5 h-5 text-blue-500" />
                  <% else %>
                    <.icon name="hero-photo" class="w-5 h-5 text-green-500" />
                  <% end %>
                  <span class="text-sm font-medium text-gray-700">{entry.client_name}</span>
                  <span class="text-xs text-gray-500">({format_bytes(entry.client_size)})</span>
                </div>
                <button
                  type="button"
                  phx-click="cancel-upload"
                  phx-value-ref={entry.ref}
                  class="text-red-600 hover:text-red-800 p-1"
                >
                  <.icon name="hero-x-mark" class="w-4 h-4" />
                </button>
              </div>

              <%= for err <- upload_errors(@uploads.attachments, entry) do %>
                <p class="text-red-600 text-sm mt-1">{error_to_string(err)}</p>
              <% end %>
            <% end %>

            <%= for err <- upload_errors(@uploads.attachments) do %>
              <p class="text-red-600 text-sm mt-2">{error_to_string(err)}</p>
            <% end %>
          </div>

          <div class="sticky bottom-0 bg-white border-t border-gray-200 p-4 -mx-4">
            <div class="flex gap-3">
              <.button
                type="submit"
                phx-disable-with="Submitting..."
                class="flex-1 py-4 text-lg font-medium bg-blue-600 text-white rounded-lg hover:bg-blue-700 touch-manipulation"
              >
                Submit Request
              </.button>
              <.button
                type="button"
                navigate={return_path(@return_to, @request)}
                class="px-6 py-4 text-lg font-medium bg-gray-200 text-gray-700 rounded-lg hover:bg-gray-300 touch-manipulation"
              >
                Cancel
              </.button>
            </div>
          </div>

          <input type="hidden" name={@form[:status].name} value="pending" />
        </.form>
      </div>
    </div>
    """
  end

  @impl true
  def mount(params, _session, socket) do
    {:ok,
     socket
     |> assign(:return_to, return_to(params["return_to"]))
     |> allow_upload(:attachments,
       accept: ~w(.jpg .jpeg .png .gif .mp4 .mov .avi .webm .m4a .mp3 .wav .ogg),
       max_entries: 5,
       max_file_size: 20_000_000
     )
     |> apply_action(socket.assigns.live_action, params)}
  end

  defp return_to("show"), do: "show"
  defp return_to(_), do: "index"

  defp apply_action(socket, :edit, %{"id" => id}) do
    request = Issues.get_request!(id)

    socket
    |> assign(:page_title, "Edit Request")
    |> assign(:request, request)
    |> assign(:form, to_form(Issues.change_request(request)))
  end

  defp apply_action(socket, :new, _params) do
    request = %Request{}

    socket
    |> assign(:page_title, "New Request")
    |> assign(:request, request)
    |> assign(:form, to_form(Issues.change_request(request)))
  end

  @impl true
  def handle_event("validate", %{"request" => request_params}, socket) do
    changeset = Issues.change_request(socket.assigns.request, request_params)
    {:noreply, assign(socket, form: to_form(changeset, action: :validate))}
  end

  def handle_event("cancel-upload", %{"ref" => ref}, socket) do
    {:noreply, cancel_upload(socket, :attachments, ref)}
  end

  def handle_event("start-speech-recognition", _params, socket) do
    # This will trigger client-side JavaScript to start speech recognition
    {:noreply, push_event(socket, "start-speech-recognition", %{})}
  end

  def handle_event("start-voice-recording", _params, socket) do
    # This will trigger client-side JavaScript to start voice recording
    {:noreply, push_event(socket, "start-voice-recording", %{})}
  end

  def handle_event("speech-result", %{"text" => text}, socket) do
    # Update the form with the speech recognition result
    changeset = socket.assigns.form.source
    current_description = Ecto.Changeset.get_field(changeset, :description) || ""

    new_description =
      if current_description == "", do: text, else: "#{current_description} #{text}"

    updated_changeset =
      changeset
      |> Ecto.Changeset.put_change(:description, new_description)

    {:noreply, assign(socket, form: to_form(updated_changeset, action: :validate))}
  end

  def handle_event("save", %{"request" => request_params}, socket) do
    # Process uploaded files

    # This would be a good place to invoke OCR on the uploaded images.
    # We could probably pull out Model or Serial nos.
    # a more advance image categorization could match vehicle and part types, but that would be
    # furhter down the features road

    uploaded_files =
      consume_uploaded_entries(socket, :attachments, fn %{path: path}, entry ->
        dest = Path.join(["priv", "static", "uploads", "#{entry.uuid}-#{entry.client_name}"])
        File.cp!(path, dest)
        {:ok, "/uploads/#{entry.uuid}-#{entry.client_name}"}
      end)

    # Add uploaded file paths to request params
    request_params_with_files = Map.put(request_params, "attachments", uploaded_files)

    save_request(socket, socket.assigns.live_action, request_params_with_files)
  end

  defp save_request(socket, :edit, request_params) do
    case Issues.update_request(socket.assigns.request, request_params) do
      {:ok, request} ->
        {:noreply,
         socket
         |> put_flash(:info, "Request updated successfully")
         |> push_navigate(to: return_path(socket.assigns.return_to, request))}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp save_request(socket, :new, request_params) do
    case Issues.create_request(request_params) do
      {:ok, request} ->
        {:noreply,
         socket
         |> put_flash(:info, "Request created successfully")
         |> push_navigate(to: return_path(socket.assigns.return_to, request))}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp return_path("index", _request), do: ~p"/requests"
  defp return_path("show", request), do: ~p"/requests/#{request}"

  defp format_bytes(bytes) when bytes < 1024, do: "#{bytes} B"
  defp format_bytes(bytes) when bytes < 1_048_576, do: "#{Float.round(bytes / 1024, 1)} KB"
  defp format_bytes(bytes), do: "#{Float.round(bytes / 1_048_576, 1)} MB"

  defp error_to_string(:too_large), do: "File too large (max 20MB)"
  defp error_to_string(:not_accepted), do: "File type not accepted"
  defp error_to_string(:too_many_files), do: "Too many files (max 5)"
  defp error_to_string(err), do: "Upload error: #{inspect(err)}"
end
