export default class AssistantChatChannel {
  constructor(socket) { 
    this.socket = socket;
    this.channel = null;
  }

  join(chatId, appendMessage) {
    const channel = this.socket.channel(`assistant_chat:${chatId}`, {});

    const appendExistingMessages = messages => messages.forEach(appendMessage)

    channel
      .join()
      .receive("ok", ({messages}) => { appendExistingMessages(messages) })
      .receive("error", res => { console.log("Unabale to join", releaseEvents) });

    channel
      .on("assistant_chat:new_message", (message) => appendMessage(message));

    this.channel = channel;
  }

  sendMessage(message) {
    if (!this.channel) { 
      throw new Error('Channel is not initiated yet.')
    }

    this.channel.push("assistant_chat:new_message", {content: message})
  }
}
