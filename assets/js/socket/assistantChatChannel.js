export default class AssistantChatChannel {
  constructor(socket, currentUserId) { 
    this.socket = socket;
    this.channel = null;
    this.currentUserId = currentUserId;
  }

  join(chatId, {onAppend, onMessageViewed, onNoMoreMessages, onPrepend}) {
    this.onPrepend = onPrepend;
    this.onNoMoreMessages = onNoMoreMessages;

    const channel = this.socket.channel(`assistant_chat:${chatId}`, {});

    const displayMessage = (message) => {
      onAppend(message);
      if (!message.was_viewed && message.sender_id !== this.currentUserId) {
        this.markMessageAsRead(message);
      }
    }

    const appendExistingMessages = messages => messages.forEach(displayMessage)

    channel
      .join()
      .receive("ok", ({messages, no_more_messages}) => { 
        appendExistingMessages(messages);
        if (no_more_messages) {
          onNoMoreMessages();
        }
      })
      .receive("error", res => { console.log("Unabale to join", res) });

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

  markMessageAsRead = (message) => {
    this.channel.push(`assistant_chat:message_viewed:${message.id}`);
  }

  loadMoreMessages() {
    if (!this.channel) { 
      throw new Error('Channel is not initiated yet.')
    }

    this.channel.push("assistant_chat:load_more_messages", {})
      .receive("ok", ({messages, no_more_messages}) => {
        this.onPrepend(messages);

        messages.forEach(message => {
          if (!message.was_viewed && message.sender_id !== this.currentUserId) {
            this.markMessageAsRead(message);
          }
        });

        if (no_more_messages) {
          this.onNoMoreMessages();
        }
      })
  }
}
