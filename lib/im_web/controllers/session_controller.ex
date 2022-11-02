defmodule ImWeb.SessionController do
  use ImWeb, :controller

  def create(conn, params) do
    IO.inspect(params)
    IO.inspect(get_session(conn, :current_user))

    send_resp(conn, :no_content, "")
  end
end
