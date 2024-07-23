import 'dart:io';

class Message {
  bool isSender;
  String msg;
  File? image;
  Message(this.isSender, this.msg, this.image);
}