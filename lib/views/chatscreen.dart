import 'package:app_messanger_by_ker/helpers/shared_pref.dart';
import 'package:app_messanger_by_ker/services/database.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:random_string/random_string.dart';

class ChatScreen extends StatefulWidget {
  final String chatWithName, chatWithUsername, chatWithProfilePic;
  ChatScreen(
      {this.chatWithName, this.chatWithUsername, this.chatWithProfilePic});

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  String myName, myUsername, myEmail, myPhoneNumber, myProfilePic;
  String chatRoomId, messageId;
  Stream messageStream;
  TextEditingController messageController = TextEditingController();

  // ini buat load data dari sharedpref dan juga buat chatroomid nya
  loadDataUserFromSharedPref() async {
    myUsername = await SharedPrefHelper().loadUsername();
    myName = await SharedPrefHelper().loadUserDisplayName();
    myEmail = await SharedPrefHelper().loadUserEmail();
    myPhoneNumber = await SharedPrefHelper().loadUserPhoneNumber();
    myProfilePic = await SharedPrefHelper().loadUserProfilePic();

    chatRoomId = createChatRoomId(myUsername, widget.chatWithUsername);
  }

  String createChatRoomId(String a, String b) {
    if (a.substring(0, 1).codeUnitAt(0) <= b.substring(0, 1).codeUnitAt(0)) {
      return "$a\_$b";
    } else {
      return "$b\_$a";
    }
  }

  sendMessage(bool sendClicked) {
    if (sendClicked) {
      if (messageController.text != "") {
        String message = messageController.text;
        var timeStamp = DateTime.now();
        if (messageId == "") {
          messageId = randomAlphaNumeric(16);
        }
        Map<String, dynamic> messageInfoMap = {
          "message": message,
          "sendByUsername": myUsername,
          "sendByName": myName,
          "timeStamp": timeStamp,
        };

        // * Kemudian data tersebut dimasukkan ke dalam database
        DatabaseService()
            .addMessagetoDatabase(chatRoomId, messageId, messageInfoMap)
            .then((value) {
          Map<String, dynamic> lastMessageInfoMap = {
            "lastMessage": message,
            "lastSendBy": myUsername,
            "lastTimeStamp": timeStamp,
            // tambahan biar mudah nantinya nampilin di Home
            "chatWith": widget.chatWithName,
            "profilePic": widget.chatWithProfilePic,
          };

          DatabaseService()
              .addLastMessageInfoIntoDatabase(chatRoomId, lastMessageInfoMap);
        });
      }
      messageController.text = "";
      messageId = "";
    }
  }

  getAndSetMessages() async {
    messageStream = await DatabaseService().getMessageFromDatabase(chatRoomId);
    setState(() {});
  }

  Widget chatContent() {
    return StreamBuilder<QuerySnapshot>(
      stream: messageStream,
      builder: (context, snapshot) {
        return snapshot.hasData
            ? ListView.builder(
                padding: EdgeInsets.only(bottom: 55, left: 5, right: 5),
                shrinkWrap: true,
                reverse: true,
                physics: ClampingScrollPhysics(),
                itemCount: snapshot.data.docs.length,
                itemBuilder: (context, index) {
                  DocumentSnapshot ds = snapshot.data.docs[index];
                  return chatContentTile(
                      ds["message"], ds["sendByUsername"] == myUsername);
                },
              )
            : Container();
      },
    );
  }

  Widget chatContentTile(String messageContent, bool sendByMe) {
    return Row(
      mainAxisAlignment:
          sendByMe ? MainAxisAlignment.end : MainAxisAlignment.start,
      children: [
        Flexible(
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            margin: EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: Colors.blue[400],
              borderRadius: BorderRadius.only(
                topLeft: sendByMe ? Radius.circular(24) : Radius.zero,
                bottomRight: sendByMe ? Radius.zero : Radius.circular(24),
                topRight: sendByMe ? Radius.circular(12) : Radius.circular(24),
                bottomLeft:
                    sendByMe ? Radius.circular(24) : Radius.circular(12),
              ),
            ),
            child: Text(
              messageContent,
              style: TextStyle(color: Colors.white70),
            ),
          ),
        ),
      ],
    );
  }

  doThisFirst() async {
    await loadDataUserFromSharedPref();
    getAndSetMessages();
  }

  @override
  void initState() {
    super.initState();
    doThisFirst();
  }

  @override
  void dispose() {
    messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.chatWithName),
      ),
      body: Container(
        child: Stack(
          children: [
            // * Show Message
            chatContent(),
            // * Chat Message Bar
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black87,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        margin:
                            EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                        // padding: EdgeInsets.symmetric(horizontal: 8),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(24),
                          color: Colors.grey,
                        ),
                        child: TextField(
                          controller: messageController,
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            contentPadding:
                                EdgeInsets.symmetric(horizontal: 16),
                          ),
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        sendMessage(true);
                        print("Ini adalah hasil dari myusername : $myUsername");
                        print("Ini adalah hasil dari chatwithusername :" +
                            widget.chatWithUsername);
                      },
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        child: Icon(
                          Icons.send_to_mobile,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
