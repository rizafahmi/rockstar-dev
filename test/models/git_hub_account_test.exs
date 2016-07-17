defmodule RockstarDev.GitHubAccountTest do
  use RockstarDev.ModelCase

  alias RockstarDev.GitHubAccount

  @valid_attrs %{account_id: "some content", email: "some content", html_url: "some content", no_repo: 42, score: "120.5", username: "some content"}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = GitHubAccount.changeset(%GitHubAccount{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = GitHubAccount.changeset(%GitHubAccount{}, @invalid_attrs)
    refute changeset.valid?
  end
end
