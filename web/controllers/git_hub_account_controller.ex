defmodule RockstarDev.GitHubAccountController do
  use RockstarDev.Web, :controller

  alias RockstarDev.GitHubAccount

  def index(conn, _params) do
    github_accounts = Repo.all(GitHubAccount)
    render(conn, "index.html", github_accounts: github_accounts)
  end

  def new(conn, _params) do
    changeset = GitHubAccount.changeset(%GitHubAccount{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"git_hub_account" => git_hub_account_params}) do
    changeset = GitHubAccount.changeset(%GitHubAccount{}, git_hub_account_params)

    case Repo.insert(changeset) do
      {:ok, _git_hub_account} ->
        conn
        |> put_flash(:info, "Git hub account created successfully.")
        |> redirect(to: git_hub_account_path(conn, :index))
      {:error, changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    git_hub_account = Repo.get!(GitHubAccount, id)
    render(conn, "show.html", git_hub_account: git_hub_account)
  end

  def edit(conn, %{"id" => id}) do
    git_hub_account = Repo.get!(GitHubAccount, id)
    changeset = GitHubAccount.changeset(git_hub_account)
    render(conn, "edit.html", git_hub_account: git_hub_account, changeset: changeset)
  end

  def update(conn, %{"id" => id, "git_hub_account" => git_hub_account_params}) do
    git_hub_account = Repo.get!(GitHubAccount, id)
    changeset = GitHubAccount.changeset(git_hub_account, git_hub_account_params)

    case Repo.update(changeset) do
      {:ok, git_hub_account} ->
        conn
        |> put_flash(:info, "Git hub account updated successfully.")
        |> redirect(to: git_hub_account_path(conn, :show, git_hub_account))
      {:error, changeset} ->
        render(conn, "edit.html", git_hub_account: git_hub_account, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    git_hub_account = Repo.get!(GitHubAccount, id)

    # Here we use delete! (with a bang) because we expect
    # it to always work (and if it does not, it will raise).
    Repo.delete!(git_hub_account)

    conn
    |> put_flash(:info, "Git hub account deleted successfully.")
    |> redirect(to: git_hub_account_path(conn, :index))
  end
end
