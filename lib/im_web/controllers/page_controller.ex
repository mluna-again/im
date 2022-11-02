defmodule ImWeb.PageController do
  use ImWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
