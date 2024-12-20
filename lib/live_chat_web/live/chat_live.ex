defmodule LiveChatWeb.ChatLive do
  use LiveChatWeb, :live_view

  alias LiveChat.Chat

  def mount(_params, _session, socket) do
    if connected?(socket) do
      Phoenix.PubSub.subscribe(LiveChat.PubSub, "add_message")
      Phoenix.PubSub.subscribe(LiveChat.PubSub, "user_update")
      Phoenix.PubSub.subscribe(LiveChat.PubSub, "clear")
    end

    {:ok, assign(socket, :messages, Chat.list_messages())}
  end

  def render(assigns) do
    ~H"""
    <.svelte name="Chat" socket={@socket} props={%{messages: @messages}}/>
    """
  end

  def handle_event("message", %{"user" => user, "text" => text}, socket) do
    if String.starts_with?(text, "/clear") do
      Chat.delete_all_messages()

      Phoenix.PubSub.broadcast_from(
        LiveChat.PubSub,
        self(),
        "clear",
        :clear
      )

      {:noreply, push_event(socket, "clear", %{})}
    else
      Chat.create_message(%{ username: user, message: text })

      Phoenix.PubSub.broadcast_from(
        LiveChat.PubSub,
        self(),
        "add_message",
        {:new_message, %{user: user, text: text}}
      )

      {:noreply, socket}
    end
  end

  def handle_event("user", %{"user" => user, "action" => action}, socket) do
    Phoenix.PubSub.broadcast_from(
      LiveChat.PubSub,
      self(),
      "user_update",
      {:user_update, %{user: user, action: action}}
    )

    {:noreply, socket}
  end

  def handle_info({:new_message, message}, socket) do
    {:noreply, push_event(socket, "add_message", message)}
  end

  def handle_info(:clear, socket) do
    {:noreply, push_event(socket, "clear", %{})}
  end

  def handle_info({:user_update, %{user: user, action: action}}, socket) do
    message = user <> case action do
      "join" -> " entrou"
      "leave" -> " saiu"
      _ -> " fez algo inesperado"
    end

    {:noreply, push_event(socket, "notification", %{message: message})}
  end
end
