import 'dart:io';

class Message {
  bool isSender;
  String msg;
  File? image;
  List<String> responses;
  Message(this.isSender, this.msg, this.image) : responses = [];
}