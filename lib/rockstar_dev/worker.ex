defmodule RockstarDev.Worker do
  require IEx
  use GenServer

  ## Client API

  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, :ok, opts)
  end

  def get_detail_account(pid, username) do
    GenServer.call(pid, {:get_detail, username})
  end

  def get_email(pid, username) do
    GenServer.call(pid, {:get_email, username})
  end

  def get_total_repo(pid, username) do

  end

  ## Server API

  def init(:ok) do
    {:ok, %{}}
  end

  def handle_call({:get_detail, username}, _from, state) do
    case detail_of(username) do
      {:ok, detail} ->
        new_state = update_state(state, username)
        {:reply, detail, new_state}
      _ ->
        {:reply, :error, state}
    end
  end

  def handle_call({:get_email, username}, _from, state) do
    case get_user_email(username) do
      {:ok, detail} ->
        new_state = update_state(state, username)
        {:reply, detail, new_state}
      _ ->
        {:reply, :error, state}
    end
  end

  ## Helper Functions

  defp detail_of(username) do
    url_for(username) |> HTTPoison.get |> parse_response
  end

  def url_for(username) do
    "https://api.github.com/users/#{username}/events/public?per_page=100#{credentials}"
  end

  def parse_response({:ok, %HTTPoison.Response{body: body, status_code: 200}}) do
    body |> JSON.decode!
  end

  def parse_response(_) do
    :error
  end

  defp parse_email({:ok, %HTTPoison.Response{body: body, status_code: 200}}) do
    data = body |> JSON.decode!
    email = get_email_from_repo(data)
    IO.inspect email
    email
  end

  defp parse_email(_) do
    :error
  end

  def credentials do
    "&client_id=" <> System.get_env("GITHUB_ID") <> "&client_secret=" <> System.get_env("GITHUB_SECRET")
  end

  defp get_user_email(username) do
    url_for(username) |> HTTPoison.get |> parse_email
  end

  def update_state(old_state, username) do
    case Map.has_key?(old_state, username) do
      true ->
        Map.update!(old_state, username, &(&1 + 1))
      false ->
        Map.put_new(old_state, username, 1)
    end
  end
  defp get_email_from_repo([h|t]) do
    if Map.fetch!(h, "type") != "PushEvent" do
      get_email_from_repo(t)
    else
      Map.fetch!(h, "payload") |> Map.fetch!("commits") |> Enum.at(0) |> Map.fetch!("author") |> Map.fetch!("email")
    end
  end

  defp get_email_from_repo([]) do
    "no email found"
  end
end
