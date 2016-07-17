defmodule RockstarDev.GitHubAccount do
  require IEx
  use RockstarDev.Web, :model

  schema "github_accounts" do
    field :account_id, :string
    field :username, :string
    field :email, :string
    field :html_url, :string
    field :score, :float
    field :no_repo, :integer

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:account_id, :username, :html_url, :score])
    |> validate_required([:account_id, :username, :html_url, :score])
    |> put_email()
    |> put_repos()
  end

  defp put_email(changeset) do
    case changeset do
      %Ecto.Changeset{valid?: true, changes: %{username: username}} ->
        put_change(changeset, :email, get_email(username))
    end
  end

  defp get_email(username) do
    url = "https://api.github.com/users/" <> username <> "/events/public"

    {:ok, %HTTPoison.Response{status_code: 200, body: body}} = HTTPoison.get(url)

    data = JSON.decode!(body)

    get_email_from_repo(data)
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
        put_change(changeset, :no_repo, count_repos(username))
    end

  end

  defp count_repos(username) do
    url = "https://api.github.com/users/" <> username <> "/events/public"

    {:ok, %HTTPoison.Response{status_code: 200, body: body}} = HTTPoison.get(url)

    data = JSON.decode!(body)

    count_repos(data, 0)

  end

  defp count_repos([h|t], count) do
    count_repos(t, count + 1)
  end

  defp count_repos([], count) do
    count
  end
end
