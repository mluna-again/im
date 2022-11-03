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
      friends: user.friends,
      friend_requests: requests(user)
    }
  end

  defp requests(%{friend_requests: friend_requests}) do
    for req <- friend_requests do
      %{
        id: req.from_id,
        username: req.from.username
      }
    end
  end

  defp requests(_user), do: []
end
