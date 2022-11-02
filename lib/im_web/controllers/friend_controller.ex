defmodule ImWeb.FriendController do
  use ImWeb, :controller

  import ImWeb.UserAuth

  alias Im.Accounts

  plug :authenticate_user when action in [:send_request]

  def send_request(conn, %{"user_id" => user_id}) do
    logged_user = conn.assigns.current_user
    receiver = Accounts.get_user!(user_id)

    case Accounts.send_friend_request(logged_user, receiver) do
      {:ok, _friendship} -> send_resp(conn, :created, "")
      {:error, _error} -> send_resp(conn, :bad_request, "")
    end
  end
end
