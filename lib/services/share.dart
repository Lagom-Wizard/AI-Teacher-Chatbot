import 'package:share_plus/share_plus.dart';
import '../models/message.dart';

void shareMessage(Message msg) {
  final String messageToShare = msg.msg + 
      (msg.responses.isNotEmpty ? "\n\nResponses:\n${msg.responses.join("\n")}" : "");
  Share.share(messageToShare);
}