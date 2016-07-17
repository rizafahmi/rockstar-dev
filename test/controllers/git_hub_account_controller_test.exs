defmodule RockstarDev.GitHubAccountControllerTest do
  use RockstarDev.ConnCase

  alias RockstarDev.GitHubAccount
  @valid_attrs %{account_id: "some content", email: "some content", html_url: "some content", no_repo: 42, score: "120.5", username: "some content"}
  @invalid_attrs %{}

  test "lists all entries on index", %{conn: conn} do
    conn = get conn, git_hub_account_path(conn, :index)
    assert html_response(conn, 200) =~ "Listing github accounts"
  end

  test "renders form for new resources", %{conn: conn} do
    conn = get conn, git_hub_account_path(conn, :new)
    assert html_response(conn, 200) =~ "New git hub account"
  end

  test "creates resource and redirects when data is valid", %{conn: conn} do
    conn = post conn, git_hub_account_path(conn, :create), git_hub_account: @valid_attrs
    assert redirected_to(conn) == git_hub_account_path(conn, :index)
    assert Repo.get_by(GitHubAccount, @valid_attrs)
  end

  test "does not create resource and renders errors when data is invalid", %{conn: conn} do
    conn = post conn, git_hub_account_path(conn, :create), git_hub_account: @invalid_attrs
    assert html_response(conn, 200) =~ "New git hub account"
  end

  test "shows chosen resource", %{conn: conn} do
    git_hub_account = Repo.insert! %GitHubAccount{}
    conn = get conn, git_hub_account_path(conn, :show, git_hub_account)
    assert html_response(conn, 200) =~ "Show git hub account"
  end

  test "renders page not found when id is nonexistent", %{conn: conn} do
    assert_error_sent 404, fn ->
      get conn, git_hub_account_path(conn, :show, -1)
    end
  end

  test "renders form for editing chosen resource", %{conn: conn} do
    git_hub_account = Repo.insert! %GitHubAccount{}
    conn = get conn, git_hub_account_path(conn, :edit, git_hub_account)
    assert html_response(conn, 200) =~ "Edit git hub account"
  end

  test "updates chosen resource and redirects when data is valid", %{conn: conn} do
    git_hub_account = Repo.insert! %GitHubAccount{}
    conn = put conn, git_hub_account_path(conn, :update, git_hub_account), git_hub_account: @valid_attrs
    assert redirected_to(conn) == git_hub_account_path(conn, :show, git_hub_account)
    assert Repo.get_by(GitHubAccount, @valid_attrs)
  end

  test "does not update chosen resource and renders errors when data is invalid", %{conn: conn} do
    git_hub_account = Repo.insert! %GitHubAccount{}
    conn = put conn, git_hub_account_path(conn, :update, git_hub_account), git_hub_account: @invalid_attrs
    assert html_response(conn, 200) =~ "Edit git hub account"
  end

  test "deletes chosen resource", %{conn: conn} do
    git_hub_account = Repo.insert! %GitHubAccount{}
    conn = delete conn, git_hub_account_path(conn, :delete, git_hub_account)
    assert redirected_to(conn) == git_hub_account_path(conn, :index)
    refute Repo.get(GitHubAccount, git_hub_account.id)
  end
end
