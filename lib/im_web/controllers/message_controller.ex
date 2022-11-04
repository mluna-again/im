defmodule ImWeb.MessageController do
  use ImWeb, :controller

  alias Im.Messages
  alias Im.Accounts

  import ImWeb.UserAuth

  action_fallback ImWeb.FallbackController

  plug :authenticate_user

  @doc """
  Returns messages between *current_user* and some other user.
  """
  def show_room_messages(conn, %{"user_id" => friend_id}) do
    friend = Accounts.get_user!(friend_id)

    messages = Messages.list_messages_between_users!(conn.assigns.current_user, friend)

    render(conn, "show.json", messages: messages)
  end

  def create(conn, %{"user_id" => friend_id, "message" => message}) do
    friend = Accounts.get_user!(friend_id)

    current_user = conn.assigns.current_user

    with {:ok, message} <- Messages.add_message(current_user, friend, message) do
      render(conn, "message.json", message: message)
    end
  end
end
