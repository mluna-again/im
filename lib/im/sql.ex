defmodule Im.Sql do
  def sanitize_like_query(query) do
    String.replace(query, ~r/[^a-zA-z0-9-_\s]/iu, "")
  end
end
