defmodule GearflowWeb.Router do
  use GearflowWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {GearflowWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", GearflowWeb do
    pipe_through :browser

    live "/", RequestLive.Form, :new
    live "/requests", RequestLive.Index, :index
    live "/requests/:id", RequestLive.Show, :show
    live "/requests/:id/edit", RequestLive.Form, :edit

    live "/triage", TriageLive.Index, :index
    live "/triage/:id/edit", TriageLive.Edit, :edit
  end

  # Other scopes may use custom stacks.
  # scope "/api", GearflowWeb do
  #   pipe_through :api
  # end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:gearflow, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: GearflowWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end
end
