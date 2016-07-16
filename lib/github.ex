defmodule RockstarDev.GitHub do
  require Logger

  def zen do

    url = "https://api.github.com/zen?" <> get_credentials
    response = HTTPoison.get!(url)
    body = response.body
    Logger.info "body: #{inspect body}"
  end

  def list_repos do
    url = "https://api.github.com/user/repos"
    response = HTTPoison.get!(url, get_headers)
    IO.inspect Poison.decode(response.body)
  end

  def list_devs do
    url = "https://api.github.com/search/users?q=language:javascript+location:indonesia&per_page=1000"
    response = HTTPoison.get!(url, get_headers)
    IO.inspect Poison.decode(response.body)
  end

  def cron do
    Logger.info "Cron is running..."
  end


  defp get_credentials do
    credentials = Application.get_env(:githubapi, GitHub)
    {:client_id, client_id} = Enum.at(credentials, 0)
    {:client_secret, client_secret} = Enum.at(credentials, 1)

    "client_id=#{client_id}&client_secret=#{client_secret}"
  end

  defp get_headers do
    token = Application.get_env(:githubapi, GitHub)[:token]
    headers = [{"Authorization", "token #{token}"}]
  end
end
