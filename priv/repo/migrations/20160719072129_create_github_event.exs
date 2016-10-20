defmodule RockstarDev.Repo.Migrations.CreateGithubEvent do
  use Ecto.Migration

  def change do
    create table(:github_events) do
      add :event_id, :integer
      add :type, :string
      add :created_at, :datetime
      add :language, :string
      add :repo_name, :string
      add :github_account, references(:github_accounts, on_delete: :nothing)

      timestamps()
    end
    create index(:github_events, [:github_account])

  end
end
