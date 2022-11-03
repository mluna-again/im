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
      requests: requests(user)
    }
  end

  defp requests(%{requests: req}), do: req
  defp requests(_), do: 0
end
