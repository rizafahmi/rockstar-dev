defmodule RockstarDev.GitHub do
  require Logger
  require IEx
  
  alias RockstarDev.GitHubAccount
  alias RockstarDev.GithubEvent
  import Ecto.Query

  def zen do

    url = "https://api.github.com/zen?" <> get_credentials
    response = HTTPoison.get!(url)
    body = response.body
    Logger.info "body: #{inspect body}"
  end

  def list_repos do
    url = "https://api.github.com/user/repos"
    response = HTTPoison.get!(url, get_headers)
    IO.inspect Poison.decode(response.body)
  end

  def list_devs do
    url = "https://api.github.com/search/users?q=language:javascript+location:indonesia&per_page=10"
    response = HTTPoison.get(url, get_headers)
    
    case response do
      {:ok, result} ->
        data = Poison.decode!(result.body)
        users = Map.fetch!(data, "items")

        insert_to_db(users)
      _ ->
        "Error getting github data"
    end
  end

  def cron do
    # RockstarDev.Repo.insert %GitHubAccount{account_id: "123", username: "username", email: "email", html_url: "http://localhost/", score: 0.1, no_repo: 0}
    IO.inspect "Cron is running..."
  end


  defp get_credentials do
    credentials = Application.get_env(:rockstar_dev, GitHub)
    {:client_id, client_id} = Enum.at(credentials, 0)
    {:client_secret, client_secret} = Enum.at(credentials, 1)

    "client_id=#{client_id}&client_secret=#{client_secret}"
  end

  defp get_headers do
    token = Application.get_env(:rockstar_dev, GitHub)[:token]
    [{"Authorization", "token #{token}"}]
  end

  def insert_to_db([h|t]) do
    username = Map.fetch!(h, "login")
    changeset = RockstarDev.GitHubAccount.changeset(%GitHubAccount{},%{account_id: to_string(Map.fetch!(h, "id")), username: username, html_url: Map.fetch!(h, "html_url"), score: Map.fetch!(h, "score"), no_repo: 0})
    insert_to_db(t)

    query = from g in RockstarDev.GitHubAccount,
      where: g.username == ^username,
      select: g.username
    user = RockstarDev.Repo.all(query)

    if Enum.count(user) == 0 do
      RockstarDev.Repo.insert(changeset)
    end
  end

  def insert_to_db([]) do
    "Insert done"
  end

  def gathering_repo_data do
    devs = RockstarDev.Repo.all(RockstarDev.GitHubAccount)
    get_user_repo_data(devs)
  end

  defp get_user_repo_data([h|t]) do
    IEx.pry
    # changeset = GithubEvent.changeset(%GithubEvent{}, %{account_id: to_string(Map.fetch!(h, "id")), username: username, html_url: Map.fetch!(h, "html_url"), score: Map.fetch!(h, "score"), no_repo: 0})
  end

  defp get_user_repo_data([]) do
    "Finish gathering data"
  end
end
