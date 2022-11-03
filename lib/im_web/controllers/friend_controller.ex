defmodule ImWeb.FriendController do
  use ImWeb, :controller

  import ImWeb.UserAuth

  alias Im.Accounts

  plug :authenticate_user when action in [:send_request]

  def send_request(conn, %{"user_id" => user_id}) do
    logged_user = conn.assigns.current_user
    receiver = Accounts.get_user!(user_id)

    case Accounts.send_friend_request(logged_user, receiver) do
      {:ok, %Accounts.Friendship{}} ->
        receiver_view = ImWeb.UserView.render("user.json", %{user: receiver})

        # logged user accepted a request
        ImWeb.Endpoint.broadcast("messages:#{logged_user.id}", "remove_request", %{
          user_to_remove: receiver_view
        })

        # another user accepted a request
        user_view = ImWeb.UserView.render("user.json", %{user: logged_user})
        ImWeb.Endpoint.broadcast("messages:#{receiver.id}", "new_friend", user_view)

        send_resp(conn, :created, "")

      {:ok, %Accounts.FriendRequest{}} ->
        ImWeb.Endpoint.broadcast("messages:#{receiver.id}", "new_request", %{
          id: logged_user.id,
          username: logged_user.username
        })

        send_resp(conn, :created, "")

      {:error, _error} ->
        send_resp(conn, :bad_request, "")
    end
  end
end
