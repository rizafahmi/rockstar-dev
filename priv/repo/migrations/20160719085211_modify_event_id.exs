defmodule RockstarDev.Repo.Migrations.ModifyEventId do
  use Ecto.Migration

  def change do
    alter table(:github_events) do
      modify :event_id, :string
    end
  end
end
