defmodule GearflowWeb.RequestLive.Form do
  use GearflowWeb, :live_view

  alias Gearflow.Issues
  alias Gearflow.Issues.Request

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <.header>
        {@page_title}
        <:subtitle>Use this form to manage request records in your database.</:subtitle>
      </.header>

      <.form for={@form} id="request-form" phx-change="validate" phx-submit="save">
        <.input field={@form[:description]} type="textarea" label="Description" />
        <.input field={@form[:priority]} type="text" label="Priority" />
        <.input field={@form[:status]} type="text" label="Status" />
        <.input
          field={@form[:attachments]}
          type="select"
          multiple
          label="Attachments"
          options={[{"Option 1", "option1"}, {"Option 2", "option2"}]}
        />
        <.input field={@form[:needed_by]} type="date" label="Needed by" />
        <.input field={@form[:equipment_id]} type="text" label="Equipment" />
        <footer>
          <.button phx-disable-with="Saving..." variant="primary">Save Request</.button>
          <.button navigate={return_path(@return_to, @request)}>Cancel</.button>
        </footer>
      </.form>
    </Layouts.app>
    """
  end

  @impl true
  def mount(params, _session, socket) do
    {:ok,
     socket
     |> assign(:return_to, return_to(params["return_to"]))
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

  def handle_event("save", %{"request" => request_params}, socket) do
    save_request(socket, socket.assigns.live_action, request_params)
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
end
