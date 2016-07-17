defmodule RockstarDev.Repo.Migrations.CreateGitHubAccount do
  use Ecto.Migration

  def change do
    create table(:github_accounts) do
      add :account_id, :string
      add :username, :string
      add :email, :string
      add :html_url, :string
      add :score, :float
      add :no_repo, :integer

      timestamps()
    end

  end
end
