import 'dart:convert';
import 'dart:io';
import 'package:ai_teacher_chatbot/message.dart';
import 'package:chat_bubbles/bubbles/bubble_normal.dart';
import 'package:ai_teacher_chatbot/services/llmservice.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';

//Main widget for the chat screen//
class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  //Text controller for input field//
  final TextEditingController _controller = TextEditingController();
  final ScrollController scrollController = ScrollController();
  //All instance//
  final GroqAiService _groqaiservice = GroqAiService();
  final ImagePicker _picker = ImagePicker();
  final TextRecognizer _textRecognizer = TextRecognizer();

  // List to store chat messages//
  List<Message> msgs = [];
  bool isTyping = false;
  //Variables to store picked and cropped images//
  File? _imageFile;
  CroppedFile? _croppedFile;

  //Function to pick an image from the gallery//
  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
      await _cropImage();
    }
  }

  //Function to crop the picked image//
  Future<void> _cropImage() async {
    if (_imageFile != null) {
      final croppedFile = await ImageCropper().cropImage(
        sourcePath: _imageFile!.path,
        compressFormat: ImageCompressFormat.jpg,
        compressQuality: 100,
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: 'Cropper',
            toolbarColor: Colors.deepOrange,
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.original,
            lockAspectRatio: false,
          ),
          IOSUiSettings(
            title: 'Cropper',
          ),
        ],
      );
      if (croppedFile != null) {
        setState(() {
          _croppedFile = croppedFile;
        });
        await _processImage();
      }
    }
  }
  
  //Process cropped image and extract text//
  Future<void> _processImage() async {
    if (_croppedFile == null) return;
    final inputImage = InputImage.fromFilePath(_croppedFile!.path);
    final RecognizedText recognizedText = await _textRecognizer.processImage(inputImage);
    String extractedText = recognizedText.text;
    print(extractedText);
    sendMsg(extractedText);
  }

  //Function to send message and get response//
  void sendMsg(String prompt) async {
    _controller.clear();

    if (prompt.isNotEmpty) {
      setState(() {
        msgs.insert(0, Message(true, prompt));
        isTyping = true;
      });
      scrollController.animateTo(0.0,
          duration: const Duration(seconds: 1), curve: Curves.easeOut);
      final response = await _groqaiservice.getLLaMA3Response(prompt);

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseBody = jsonDecode(response.body);
        if (responseBody.containsKey('choices')) {
          setState(() {
            isTyping = false;
            msgs.insert(
              0,
              Message(
                false,
                responseBody["choices"][0]["message"]["content"]
                    .toString()
                    .trimLeft(),
              ),
            );
          });
          scrollController.animateTo(0.0,
              duration: const Duration(seconds: 1), curve: Curves.easeOut);
        } else {
          throw Exception('API response does not contain the expected "prompt" field');
        }
      } else {
        throw Exception('Failed to get response from LLaMA3: ${response.body}');
      }
    }
  }

  //Clean up resources//
  @override
  void dispose() {
    _textRecognizer.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Teacher Helper"),
      ),
      body: Stack(
        children: [
          Column(
            children: [
              const SizedBox(height: 8),
              // Display chat messages//
              Expanded(
                child: ListView.builder(
                  controller: scrollController,
                  itemCount: msgs.length,
                  shrinkWrap: true,
                  reverse: true,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: isTyping && index == 0
                          ? Column(
                              children: [
                                BubbleNormal(
                                  text: msgs[0].msg,
                                  isSender: true,
                                  color: Colors.blue.shade100,
                                ),
                                const Padding(
                                  padding: EdgeInsets.only(left: 16, top: 4),
                                  child: Align(
                                      alignment: Alignment.centerLeft,
                                      child: Text("Typing...")),
                                )
                              ],
                            )
                          : BubbleNormal(
                              text: msgs[index].msg,
                              isSender: msgs[index].isSender,
                              color: msgs[index].isSender
                                  ? Colors.blue.shade100
                                  : Colors.grey.shade200,
                            ),
                    );
                  },
                ),
              ),
              // Input field and send button//
              Row(
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Container(
                        width: double.infinity,
                        height: 40,
                        decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(10)),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: TextField(
                            controller: _controller,
                            textCapitalization: TextCapitalization.sentences,
                            onSubmitted: (value) {
                              sendMsg(value);
                            },
                            textInputAction: TextInputAction.send,
                            showCursor: true,
                            decoration: const InputDecoration(
                                border: InputBorder.none, hintText: "Type a prompt"),
                          ),
                        ),
                      ),
                    ),
                  ),

                  //Send message button//
                  InkWell(
                    onTap: () {
                      sendMsg(_controller.text);
                    },
                    child: Container(
                      height: 40,
                      width: 40,
                      decoration: BoxDecoration(
                          color: Colors.blue,
                          borderRadius: BorderRadius.circular(30)),
                      child: const Icon(
                        Icons.send,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),

                  //Pick image button//
                  InkWell(
                    onTap: _pickImage,
                    child: Container(
                      height: 40,
                      width: 40,
                      decoration: BoxDecoration(
                          color: Colors.blue,
                          borderRadius: BorderRadius.circular(30)),
                      child: const Icon(
                        Icons.image,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),

          // Show 'Pick Image' button when no messages are showed//
          if (msgs.isEmpty) Center(
            child: ElevatedButton.icon(
              onPressed: _pickImage,
              icon: const Icon(Icons.image, size: 48),
              label: const Text("Pick Image", style: TextStyle(fontSize: 24)),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
