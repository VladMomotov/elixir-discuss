export default class AssistantChatChannel {
  constructor(socket, currentUserId) { 
    this.socket = socket;
    this.channel = null;
    this.currentUserId = currentUserId;
  }

  join(chatId, {onAppend, onMessageViewed}) {
    const channel = this.socket.channel(`assistant_chat:${chatId}`, {});

    const markMessageAsRead = (message) => {
      channel.push(`assistant_chat:message_viewed:${message.id}`);
    }

    const displayMessage = (message) => {
      onAppend(message);
      if (!message.was_viewed && message.sender_id !== this.currentUserId) {
        markMessageAsRead(message);
      }
    }

    const appendExistingMessages = messages => messages.forEach(displayMessage)

    channel
      .join()
      .receive("ok", ({messages}) => { appendExistingMessages(messages) })
      .receive("error", res => { console.log("Unabale to join", releaseEvents) });

    channel
      .on("assistant_chat:new_message", displayMessage);

    channel
      .on("assistant_chat:message_viewed", onMessageViewed);

    this.channel = channel;
  }

  sendMessage(message) {
    if (!this.channel) { 
      throw new Error('Channel is not initiated yet.')
    }

    this.channel.push("assistant_chat:new_message", {content: message})
  }
}
