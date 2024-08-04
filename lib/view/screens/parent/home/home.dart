import 'package:agora_rtm/agora_rtm.dart';
import 'package:provider/provider.dart';
import 'package:schoolcrm/model/logs.dart';
import 'package:schoolcrm/model/message_model.dart';
import 'package:flutter/material.dart';
import 'package:schoolcrm/view/components/app_bar_style.dart';
import 'package:schoolcrm/view/components/time.dart';
import 'package:schoolcrm/view/consatans/colors.dart';
import 'package:schoolcrm/view/consatans/fonts.dart';
import 'package:schoolcrm/view/screens/common/chat_group/message.dart';
import 'package:schoolcrm/view/screens/common/login/auth.dart';
import 'package:schoolcrm/view/screens/parent/home/componants/absences.dart';
import 'package:schoolcrm/view/screens/parent/home/componants/financial_fees.dart';
import 'package:schoolcrm/view/screens/parent/home/componants/open_gmail.dart';
import 'package:schoolcrm/view/screens/parent/home/drawer/drawer.dart';

class Home extends StatefulWidget {
  bool isLoaded = false;
  bool isPressed = false;

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  late AgoraRtmClient _client;
  late AgoraRtmChannel _channel;
  final ObjectLogController _logController = ObjectLogController();
  final LogController _oldLog = LogController();
  final String appId = "bb63209254774326bc95604ee1057f2e";
  late String nameOfUser;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance?.addPostFrameCallback((_) {
      nameOfUser = Provider.of<Auth>(context, listen: false).getName();
      print("Name of the user is $nameOfUser");
      createClient();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Drawer(
        backgroundColor: Colors.transparent,
        child: ManagerDrawer(),
      ),
      appBar: AppBar(
        systemOverlayStyle: systemOverlayStyle,
        shape: shape,
        backgroundColor: primaryColor,
        shadowColor: primaryColor,
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: secondaryColor,
        child: Icon(Icons.forward_to_inbox_outlined, color: primaryColor),
        onPressed: () {
          openGmail(context);
        },
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.all(20),
          height: MediaQuery.of(context).size.height,
          color: secondaryColorLight,
          child: Column(
            children: [
              AbsencesContainer(),
              SizedBox(height: MediaQuery.of(context).size.height - 830),
              AbsencesContainer(),
            ],
          ),
        ),
      ),
    );
  }

  void createClient() async {
    _client = await AgoraRtmClient.createInstance(appId);
    _client.onMessageReceived = (AgoraRtmMessage message, String peerId) {
      _logController.addLog(MessageModel(
          message: message.text,
          userId: peerId,
          time: Time().getCurrentTime()));
    };
    login(context);
  }

  void login(BuildContext context) async {
    String userId = nameOfUser;
    try {
      await _client.login(null, userId);
      joinChannel(context);
    } catch (errorCode) {
      print('Login error: ' + errorCode.toString());
    }
  }

  void joinChannel(BuildContext context) async {
    try {
      _channel = await createChannel("School");
      await _channel.join();

      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => MessageScreen(
                client: _client,
                channel: _channel,
                logController: _oldLog,
                objectLogController: _logController,
                userId: nameOfUser,
              )));
    } catch (errorCode) {
      print('Join channel error: ' + errorCode.toString());
    }
  }

  Future<AgoraRtmChannel> createChannel(String name) async {
    AgoraRtmChannel channel = await _client.createChannel(name);

    channel.onMessageReceived =
        (AgoraRtmMessage message, AgoraRtmMember member) {
      _logController.addLog(MessageModel(
          message: message.text,
          userId: member.userId,
          time: Time().getCurrentTime()));
    };
    return channel;
  }

  Future<bool> isOnline() async {
    Map<dynamic, dynamic> result =
    await _client.queryPeersOnlineStatus([nameOfUser]);

    if (result[nameOfUser] == true) {
      print(result.toString());
      return true;
    } else {
      print(result.toString());
      return false;
    }
  }
}