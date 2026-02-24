/// Message kind/type from server (MessageItem.MessageKind raw values).
/// See MessageItem.swift MessageKind.
enum MessageType {
  actionRequest,
  contactInformationRequest,
  contactInformation,
  fileFromOperator,
  fileFromVisitor,
  forOperator,
  info,
  keyboard,
  keyboardResponse,
  operatorMessage,
  operatorBusy,
  stickerVisitor,
  visitorMessage,
  unknown,
}

extension MessageTypeParser on MessageType {
  static MessageType fromString(String? value) {
    if (value == null || value.isEmpty) return MessageType.unknown;
    switch (value) {
      case 'action_request':
        return MessageType.actionRequest;
      case 'cont_req':
        return MessageType.contactInformationRequest;
      case 'contacts':
        return MessageType.contactInformation;
      case 'file_operator':
        return MessageType.fileFromOperator;
      case 'file_visitor':
        return MessageType.fileFromVisitor;
      case 'for_operator':
        return MessageType.forOperator;
      case 'info':
        return MessageType.info;
      case 'keyboard':
        return MessageType.keyboard;
      case 'keyboard_response':
        return MessageType.keyboardResponse;
      case 'operator':
        return MessageType.operatorMessage;
      case 'operator_busy':
        return MessageType.operatorBusy;
      case 'sticker_visitor':
        return MessageType.stickerVisitor;
      case 'visitor':
        return MessageType.visitorMessage;
      default:
        return MessageType.unknown;
    }
  }
}
