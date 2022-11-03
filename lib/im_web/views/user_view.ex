defmodule ImWeb.UserView do
  use ImWeb, :view
  alias ImWeb.UserView

  def render("index.json", %{users: users}) do
    render_many(users, UserView, "user.json")
  end

  def render("show.json", %{user: user}) do
    render_one(user, UserView, "user.json")
  end

  def render("user.json", %{user: user}) do
    %{
      id: user.id,
      username: user.username,
      invitation_sent: user.invitation_sent,
      invitation_received: user.invitation_received,
      # this is a boolean that checks if logged user is friends with *this* user
      friends_with_logged: friends_with_logged(user),
      friend_requests: requests(user),
      friends: friends(user)
    }
  end

  defp friends_with_logged(%{friends_with_logged: friends_with_logged}) do
    friends_with_logged
  end

  defp friends_with_logged(_), do: false

  defp requests(%{friend_requests: friend_requests}) do
    for req <- friend_requests do
      %{
        id: req.from_id,
        username: req.from.username
      }
    end
  end

  defp requests(_user), do: []

  defp friends(%{friends: friends}), do: friends

  defp friends(_user), do: []
end
