defmodule RockstarDev.Repo.Migrations.AddCheckedField do
  use Ecto.Migration

  def change do
    alter table(:github_accounts) do
      add :checked, :boolean, default: false
    end
  end
end
