import 'package:agora_rtm/agora_rtm.dart';
import 'package:flutter/material.dart';
import 'package:schoolcrm/model/logs.dart';
import 'package:schoolcrm/model/message_model.dart';
import 'package:schoolcrm/view/components/app_bar_style.dart';
import 'package:schoolcrm/view/components/time.dart';
import 'package:schoolcrm/view/consatans/colors.dart';
import 'package:schoolcrm/view/screens/common/chat_group/custom_ui/emoji_keyboard.dart';
import 'package:schoolcrm/view/screens/common/chat_group/custom_ui/own_message_card.dart';
import 'package:schoolcrm/view/screens/common/chat_group/custom_ui/reply_card.dart';

class MessageScreen extends StatefulWidget {
  final AgoraRtmClient client;
  final AgoraRtmChannel channel;
  final ObjectLogController objectLogController;
  final LogController logController;
  final String userId;

  MessageScreen({
    required this.client,
    required this.channel,
    required this.logController,
    required this.objectLogController,
    required this.userId,
  });

  @override
  _MessageScreenState createState() => _MessageScreenState();
}

class _MessageScreenState extends State<MessageScreen> {
  final _peerUserId = TextEditingController();
  final _channelMessageController = TextEditingController();
  bool emojiPickerIsShowed = false;
  FocusNode focusNode = FocusNode();
  ScrollController scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    focusNode.addListener(() {
      if (focusNode.hasFocus) {
        setState(() {
          emojiPickerIsShowed = false;
        });
      }
    });
  }

  Future<void> _sendChannelMessage() async {
    if (_channelMessageController.text.isEmpty) {
      widget.logController.addLog('Please input text to send.');
      return;
    }
    try {
      await widget.channel.sendMessage(
          AgoraRtmMessage.fromText(_channelMessageController.text));

      widget.logController.addLog(
          '${_channelMessageController.text} Send channel message success.');

      widget.objectLogController.addLog(MessageModel(
        message: _channelMessageController.text,
        userId: widget.userId,
        time: Time().getCurrentTime(),
      ));
    } catch (errorCode) {
      widget.logController
          .addLog('Send channel message error: ' + errorCode.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: primaryColor,
        title: Text(
          "غرفة المحادثة",
          style: TextStyle(fontFamily: "Readex_Pro"),
        ),
        leading: BackButton(
          onPressed: () {
            widget.client.logout();
            Navigator.pop(context);
          },
        ),
      ),
      body: Container(
        child: WillPopScope(
          onWillPop: () async {
            if (emojiPickerIsShowed) {
              setState(() {
                emojiPickerIsShowed = !emojiPickerIsShowed;
              });
            } else {
              widget.client.logout();
              Navigator.pop(context);
            }
            return false;
          },
          child: Stack(
            children: [
              Container(
                height: MediaQuery.of(context).size.height,
                width: MediaQuery.of(context).size.width,
                child: Image.asset(
                  "assets/images/whats_app_background _image.png",
                  fit: BoxFit.fill,
                ),
              ),
              Align(
                alignment: Alignment.topRight,
                child: Container(
                  height: MediaQuery.of(context).size.height * 0.8,
                  child: ValueListenableBuilder<List<MessageModel>>(
                    valueListenable: widget.objectLogController,
                    builder: (context, log, child) {
                      return ListView.builder(
                        controller: scrollController,
                        itemCount: log.length,
                        itemBuilder: (context, index) {
                          final message = log[log.length - 1 - index];
                          if (message.userId == widget.userId) {
                            return OwnMessageCard(
                              message: message.message,
                              time: message.time,
                            );
                          } else {
                            return ReplyCard(
                              message: message.message,
                              time: message.time,
                              userId: message.userId,
                            );
                          }
                        },
                      );
                    },
                  ),
                ),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Card(
                            margin: EdgeInsets.only(left: 10, right: 5, bottom: 20),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25),
                            ),
                            child: TextFormField(
                              controller: _channelMessageController,
                              focusNode: focusNode,
                              minLines: 1,
                              maxLines: 5,
                              cursorColor: Colors.grey.shade400,
                              textAlignVertical: TextAlignVertical.center,
                              keyboardType: TextInputType.multiline,
                              enableSuggestions: false,
                              autocorrect: false,
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                hintText: "Message",
                                contentPadding: EdgeInsets.all(5),
                                prefixIcon: IconButton(
                                  onPressed: () {
                                    focusNode.unfocus();
                                    focusNode.canRequestFocus = false;
                                    setState(() {
                                      emojiPickerIsShowed =
                                      !emojiPickerIsShowed;
                                    });
                                  },
                                  icon: Icon(
                                    Icons.emoji_emotions_outlined,
                                    color: primaryColor,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 20),
                          child: CircleAvatar(
                            backgroundColor: primaryColor,
                            child: IconButton(
                              icon: Icon(Icons.send, color: Colors.white),
                              onPressed: () async {
                                await _sendChannelMessage();
                                _channelMessageController.clear();
                                scrollToBottom();
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                    emojiPickerIsShowed
                        ? Container(
                      height: 280,
                      child: EmojiPad(
                        controller: _channelMessageController,
                      ),
                    )
                        : Container(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void scrollToBottom() {
    WidgetsBinding.instance!.addPostFrameCallback((_) {
      scrollController.animateTo(
        scrollController.position.maxScrollExtent,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  void dispose() {
    _peerUserId.dispose();
    _channelMessageController.dispose();
    focusNode.dispose();
    scrollController.dispose();
    super.dispose();
  }
}