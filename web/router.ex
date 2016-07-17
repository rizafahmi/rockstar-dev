defmodule RockstarDev.Router do
  use RockstarDev.Web, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", RockstarDev do
    pipe_through :browser # Use the default browser stack

    get "/", PageController, :index
    resources "/github_accounts", GitHubAccountController
  end

  # Other scopes may use custom stacks.
  # scope "/api", RockstarDev do
  #   pipe_through :api
  # end
end
