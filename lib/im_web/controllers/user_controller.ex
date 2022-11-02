defmodule ImWeb.UserController do
  use ImWeb, :controller

  alias Im.Accounts
  alias Im.Accounts.User

  action_fallback ImWeb.FallbackController

  @one_day 86400

  def index(conn, params) do
    users = Accounts.list_users(params)
    render(conn, "index.json", users: users)
  end

  def create(conn, %{"user" => user_params}) do
    with {:ok, %User{} = user} <- Accounts.create_user(user_params) do
      conn
      |> put_status(:created)
      |> render("show.json", user: user)
    end
  end

  def show(conn, %{"id" => id}) do
    user = Accounts.get_user!(id)
    render(conn, "show.json", user: user)
  end

  def show_logged(conn, _params) do
    Process.sleep(500)
    token = get_session(conn, :user_token)

    user_id =
      token && Phoenix.Token.verify(ImWeb.Endpoint, "user_token", token, max_age: @one_day)

    case user_id do
      {:ok, id} ->
        user = Accounts.get_user!(id)
        render(conn, "show.json", user: user)

      {:error, _error} ->
        send_resp(conn, :unauthorized, "")

      nil ->
        send_resp(conn, :unauthorized, "")
    end
  end

  def update(conn, %{"id" => id, "user" => user_params}) do
    user = Accounts.get_user!(id)

    with {:ok, %User{} = user} <- Accounts.update_user(user, user_params) do
      render(conn, "show.json", user: user)
    end
  end

  def delete(conn, %{"id" => id}) do
    user = Accounts.get_user!(id)

    with {:ok, %User{}} <- Accounts.delete_user(user) do
      send_resp(conn, :no_content, "")
    end
  end
end
