defmodule LiveChatWeb.ChatLive do
  use LiveChatWeb, :live_view

  def mount(_params, _session, socket) do
    if connected?(socket), do: Phoenix.PubSub.subscribe(LiveChat.PubSub, "add_message")
    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <.svelte name="Chat" socket={@socket} />
    """
  end

  def handle_event("message", %{"user" => user, "text" => text}, socket) do
    Phoenix.PubSub.broadcast_from(
      LiveChat.PubSub,
      self(),
      "add_message",
      {:new_message, %{user: user, text: text}}
    )

    {:noreply, socket}
  end

  def handle_info({:new_message, message}, socket) do
    {:noreply, push_event(socket, "add_message", message)}
  end
end
