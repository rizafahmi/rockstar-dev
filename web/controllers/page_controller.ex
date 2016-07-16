defmodule RockstarDev.PageController do
  use RockstarDev.Web, :controller

  def index(conn, _params) do
    {:ok, %HTTPoison.Response{status_code: 200, body: body}} = HTTPoison.get("https://api.github.com/search/users?q=language:javascript+location:Indonesia&per_page=100", [{"Authorization", "token bfdd5602edae8b1ceb12ac203bd5acd84c08e353"}])

    data = JSON.decode!(body)

    users = Map.fetch!(data, "items")

    render conn, "index.html", users: users
  end
end
