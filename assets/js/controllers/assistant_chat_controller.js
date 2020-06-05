import { Controller } from 'stimulus'

const NOT_VIEWED_MESSAGE_CLASS = "not-viewed";

export default class extends Controller {
  static targets = [ "collection", "input", "loadMoreButton" ];

  initialize() {
    const chatId = this.data.get("chatId");
    window.assistantChatChannel.join(chatId, 
      {
        onAppend: this.appendMessage,
        onMessageViewed: this.markMessageAsViewed,
        onNoMoreMessages: this.hideLoadMoreButton,
        onPrepend: this.prependMessages,
      }
    );
  }

  submit(event) {
    event.preventDefault();

    window.assistantChatChannel.sendMessage(this.inputTarget.value);
    this.inputTarget.value = "";

  }

  loadMore(event) {
    window.assistantChatChannel.loadMoreMessages();
  }

  appendMessage = (message) => {
    $(this.collectionTarget).append(this.messageTemplate(message))
  }

  prependMessages = (messages) => {
    const messagesTemplate = messages.map(message => this.messageTemplate(message)).join('\n');
    $(this.collectionTarget).prepend(messagesTemplate);
  }

  markMessageAsViewed = (message) => {
    const messageElement = $(this.collectionTarget).find(`li[data-assistant-chat-message-id='${message.id}']`)[0];
    messageElement.classList.remove(NOT_VIEWED_MESSAGE_CLASS);
  }

  hideLoadMoreButton = () => {
    this.loadMoreButtonTarget.style.display = "none";
  }

  messageTemplate = (message) => {
    const currentUserId = window.userId;

    const isCurrentUserSender = message.sender_id === currentUserId;
    const viewedClass = message.was_viewed ? '' : NOT_VIEWED_MESSAGE_CLASS;

    return `
    <li 
      class="message collection-item ${isCurrentUserSender ? 'right-align' : 'left-align'} ${viewedClass}"
      data-assistant-chat-message-id="${message.id}"
    >
      <span>${message.content}</span>
    </li>
    `
  }
}
