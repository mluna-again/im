defmodule Im.MessagesFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Im.Messages` context.
  """

  @doc """
  Generate a message.
  """
  def message_fixture(attrs \\ %{}) do
    {:ok, message} =
      attrs
      |> Enum.into(%{
        content: "some content"
      })
      |> Im.Messages.create_message()

    message
  end
end
