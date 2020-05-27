import { Controller } from 'stimulus'

const NOT_VIEWED_MESSAGE_CLASS = "not-viewed";

export default class extends Controller {
  static targets = [ "collection", "input" ];

  initialize() {
    const chatId = this.data.get("chatId");
    window.assistantChatChannel.join(chatId, 
      {
        onAppend: this.appendMessage,
        onMessageViewed: this.markMessageAsViewed
      }
    );
  }

  submit(event) {
    event.preventDefault();

    window.assistantChatChannel.sendMessage(this.inputTarget.value);
    this.inputTarget.value = "";

  }

  appendMessage = (message) => {
    const currentUserId = window.userId;

    const isCurrentUserSender = message.sender_id === currentUserId;
    const viewedClass = message.was_viewed ? '' : NOT_VIEWED_MESSAGE_CLASS;

    $(this.collectionTarget).append(`
    <li 
      class="message collection-item ${isCurrentUserSender ? 'right-align' : 'left-align'} ${viewedClass}"
      data-assistant-chat-message-id="${message.id}"
    >
      <span>${message.content}</span>
    </li>
    `)
  }

  markMessageAsViewed = (message) => {
    const messageElement = $(this.collectionTarget).find(`li[data-assistant-chat-message-id='${message.id}']`)[0];
    messageElement.classList.remove(NOT_VIEWED_MESSAGE_CLASS);
  }
}
