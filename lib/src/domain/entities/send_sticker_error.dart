/// See SendStickerError in ActionRequestLoop.
enum SendStickerError implements Exception {
  noStickerId,
  noChat,
  unknown,
}
