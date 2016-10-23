defmodule RockstarDev.GitHubAccount do
  require IEx
  alias RockstarDev.GitHubAccount
  alias RockstarDev.Repo

  use RockstarDev.Web, :model

  schema "github_accounts" do
    field :account_id, :string
    field :username, :string
    field :email, :string
    field :html_url, :string
    field :score, :float
    field :no_repo, :integer
    field :repo_created, :integer
    field :repo_pushed, :integer
    field :checked, :boolean
    has_many :github_events, RockstarDev.GithubEvent

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:account_id, :username, :html_url, :score, :checked])
    |> validate_required([:account_id, :username, :html_url, :score])
    |> put_email()
    # |> put_repos()
  end

  defp put_email(changeset) do
    case changeset do
      %Ecto.Changeset{valid?: true, changes: %{username: username}} ->
        put_change(changeset, :email, get_email(username))
      _ ->
        put_change(changeset, :email, "no email found, yet")
    end
  end

  defp get_email(username) do
    url = "https://api.github.com/users/" <> username <> "/events/public?per_page=50" <> credentials

    case HTTPoison.get(url) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        data = JSON.decode!(body)
        get_email_from_repo(data)
      _ ->
        "no email found, yet"
    end
  end

  defp get_email_from_repo([h|t]) do
    if Map.fetch!(h, "type") != "PushEvent" do
      get_email_from_repo(t)
    else
      Map.fetch!(h, "payload") |> Map.fetch!("commits") |> Enum.at(0) |> Map.fetch!("author") |> Map.fetch!("email")
    end
  end

  defp get_email_from_repo([]) do
    "no email found"
  end

  defp put_repos(changeset) do
    case changeset do
      %Ecto.Changeset{valid?: true, changes: %{username: username}} ->
        no_repo_created = count_repos(username, "CreateEvent")
        if no_repo_created == nil do
          no_repo_created = 0
        end

        no_repo_pushed = count_repos(username, "PushEvent")
        if no_repo_pushed == nil do
          no_repo_pushed = 0
        end

        total_repos = no_repo_created + no_repo_pushed
        put_change(changeset, :no_repo, total_repos)
        put_change(changeset, :repo_created, no_repo_created)
        put_change(changeset, :repo_pushed, no_repo_pushed)
    end

  end

  def count_all_repos(username, page, type) do
    url = "https://api.github.com/users/" <> username <> "/events/public?per_page=100&page=#{page}" <> credentials

    case HTTPoison.get(url) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        data = JSON.decode!(body)
        count_repos(data, type, 0)
      _ ->
        0
    end

  end

  def count_repos([h|t], type, count) do
    IO.inspect(Enum.count(t))
    if Map.fetch!(h, "type") == type do
      count_repos(t, type, count + 1)
    end
  end

  def count_repos([], type, count) do
    IO.inspect("Finish counting...")
    count
  end

  defp credentials do
    "&client_id=" <> System.get_env("GITHUB_ID") <> "&client_secret=" <> System.get_env("GITHUB_SECRET")
  end


  def update_and_get_repos do
    query = from g in "github_accounts",
      where: g.email == "no email found",
      select: {g.id, g.email, g.username}
    Repo.all(query)
  end
end
