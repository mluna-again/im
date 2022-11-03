defmodule ImWeb.SessionController do
  use ImWeb, :controller

  alias Im.Accounts

  def create(conn, %{"user" => user}) do
    %{"username" => username, "password" => password} = user

    if user = Accounts.get_user_by_username_and_password!(username, password) do
      token = Phoenix.Token.sign(ImWeb.Endpoint, "user_token", user.id)

      conn
      |> renew_session()
      |> put_session(:user_token, token)
      |> json(%{token: token})
    else
      send_resp(conn, :unauthorized, "")
    end
  end

  def delete(conn, _params) do
    conn
    |> renew_session()
    |> send_resp(:ok, "")
  end

  defp renew_session(conn) do
    conn
    |> configure_session(renew: true)
    |> clear_session()
  end
end
