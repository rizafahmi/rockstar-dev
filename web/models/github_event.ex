defmodule RockstarDev.GithubEvent do
  use RockstarDev.Web, :model

  schema "github_events" do
    field :event_id, :integer
    field :type, :string
    field :created_at, Ecto.DateTime
    field :language, :string
    field :repo_name, :string
    belongs_to :username, RockstarDev.Username

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:event_id, :type, :created_at, :language, :repo_name])
    |> validate_required([:event_id, :type, :created_at, :language, :repo_name])
  end
end
