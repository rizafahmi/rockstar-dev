defmodule RockstarDev.PageView do
  require IEx
  use RockstarDev.Web, :view

  def get_email(username) do
    url = "https://api.github.com/users/" <> username <> "/events/public"

    {:ok, %HTTPoison.Response{status_code: 200, body: body}} = HTTPoison.get(url)

    data = JSON.decode!(body)

    get_email_from_repo(data)

  end

  defp get_email_from_repo([h|t]) do
    if Map.fetch!(h, "type") != "PushEvent" do
      get_email_from_repo(t)
    else
      Map.fetch!(h, "payload") |> Map.fetch!("commits") |> Enum.at(0) |> Map.fetch!("author") |> Map.fetch!("email")
    end
  end

  defp get_email_from_repo([]) do
    "None"
  end

end
