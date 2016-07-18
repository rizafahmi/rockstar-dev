defmodule RockstarDev.Repo.Migrations.AddRepoCreatedAndRepoPushed do
  use Ecto.Migration

  def change do
    alter table(:github_accounts) do
      add :repo_created, :integer
      add :repo_pushed, :integer
    end
  end
end
