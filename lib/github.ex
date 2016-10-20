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

  def list_devs(per_page) do
    url = "https://api.github.com/search/users?q=language:javascript+location:indonesia&per_page=" <> to_string(per_page)
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

    query = from g in RockstarDev.GitHubAccount,
      where: g.username == ^username,
      select: g.username
    user = RockstarDev.Repo.all(query)

    if Enum.count(user) == 0 do
      RockstarDev.Repo.insert(changeset)
    end

    insert_to_db(t)
  end

  def insert_to_db([]) do
    "Insert done"
  end

  def gathering_repo_data do
    devs = RockstarDev.Repo.all(RockstarDev.GitHubAccount)
    get_user_repo_data(devs)
  end

  defp get_user_repo_data([h|t]) do
    username = Map.fetch!(h, :username)
    url = "https://api.github.com/users/" <> username <> "/events/public?per_page=5"

    case HTTPoison.get(url) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        data = JSON.decode!(body)
        insert_repo(data)
      _ ->
        "no events found"
    end
  end

  defp get_user_repo_data([]) do
    "Finish gathering data"
  end

  defp insert_repo([h|t]) do
    %{"id" => id, "repo" => %{"url"=> url}, "type" => type, "actor" => %{"login" => login}} = Map.take(h, ["id", "type", "repo", "actor"])

    # changeset = GithubEvent.changeset(%GithubEvent{}, %{event_id: id, type: type, repo_name: url})
    
    user = RockstarDev.Repo.get_by!(RockstarDev.GitHubAccount, username: login)

    attrs = %{event_id: id, type: type, repo_name: url}
    repo = Ecto.build_assoc(user, :github_events, attrs)

    query = from e in RockstarDev.GithubEvent,
      where: e.event_id == ^id,
      select: e
    events = RockstarDev.Repo.all(query)

    if Enum.count(events) == 0 do
      RockstarDev.Repo.insert(repo)
    end

    insert_repo(t)
  end

  defp insert_repo([]) do
    "Done insert repo to db"
    end
end
