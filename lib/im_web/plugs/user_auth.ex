defmodule ImWeb.UserAuth do
  import Plug.Conn

  alias Im.Accounts

  @one_day 86400

  def authenticate_user(conn, _opts) do
    token = get_session(conn, :user_token)

    user_id =
      token && Phoenix.Token.verify(ImWeb.Endpoint, "user_token", token, max_age: @one_day)

    case user_id do
      {:ok, id} ->
        conn
        |> assign(:current_user, Accounts.get_user!(id))

      {:error, _error} ->
        conn
        |> halt()
        |> send_resp(:unauthorized, "")

      nil ->
        conn
        |> halt()
        |> send_resp(:unauthorized, "")
    end
  end
end
