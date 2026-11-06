class ChatMessage {
  ChatMessage(this.author, this.text, {this.read = true});
  final String author, text;
  bool read;
}
