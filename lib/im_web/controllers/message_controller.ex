defmodule ImWeb.MessageController do
  use ImWeb, :controller

  alias Im.Messages
  alias Im.Accounts

  import ImWeb.UserAuth

  plug :authenticate_user

  @doc """
  Returns messages between *current_user* and some other user.
  """
  def show_room_messages(conn, %{"user_id" => friend_id}) do
    friend = Accounts.get_user!(friend_id)

    messages = Messages.list_messages_between_users!(conn.assigns.current_user, friend)

    render(conn, "show.json", messages: messages)
  end
end
