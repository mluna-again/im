defmodule ImWeb.MessagesChannel do
  use ImWeb, :channel

  @typing_timeout 3000

  @impl true
  def join("messages:" <> user_id, _payload, socket) do
    if authorized?(socket, user_id) do
      {:ok, assign(socket, :current_user, user_id)}
    else
      {:error, %{reason: "unauthorized"}}
    end
  end

  @impl true
  def handle_in("typing", %{"to" => to}, socket) do
    timer = Map.get(socket.assigns, :timer_ref)
    if timer, do: Process.cancel_timer(timer)
    ImWeb.Endpoint.broadcast("messages:#{to}", "typing", %{from: socket.assigns.current_user})

    timer_ref = Process.send_after(self(), {:send_stop_typing, to}, @typing_timeout)
    socket = assign(socket, :timer_ref, timer_ref)
    {:noreply, socket}
  end

  @impl true
  def handle_info({:send_stop_typing, to}, socket) do
    ImWeb.Endpoint.broadcast("messages:#{to}", "stop_typing", %{from: socket.assigns.current_user})

    {:noreply, socket}
  end

  # Add authorization logic here as required.
  defp authorized?(socket, user_id) do
    to_string(socket.assigns.user_id) == user_id
  end
end
