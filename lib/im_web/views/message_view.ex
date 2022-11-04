defmodule ImWeb.MessageView do
  use ImWeb, :view
  alias ImWeb.MessageView

  def render("show.json", %{messages: messages}) do
    render_many(messages, MessageView, "message.json")
  end

  def render("message.json", %{message: message}) do
    %{
      id: message.id,
      user: message.user
    }
  end
end
