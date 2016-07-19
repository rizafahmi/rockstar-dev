defmodule RockstarDev.GithubEventTest do
  use RockstarDev.ModelCase

  alias RockstarDev.GithubEvent

  @valid_attrs %{created_at: %{day: 17, hour: 14, min: 0, month: 4, sec: 0, year: 2010}, event_id: 42, language: "some content", repo_name: "some content", type: "some content"}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = GithubEvent.changeset(%GithubEvent{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = GithubEvent.changeset(%GithubEvent{}, @invalid_attrs)
    refute changeset.valid?
  end
end
