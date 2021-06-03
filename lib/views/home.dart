import 'package:app_messanger_by_ker/helpers/shared_pref.dart';
import 'package:app_messanger_by_ker/services/auth.dart';
import 'package:app_messanger_by_ker/services/database.dart';
import 'package:app_messanger_by_ker/views/chatscreen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  bool isSearching;
  TextEditingController searchController = TextEditingController();
  Stream<QuerySnapshot> listSearchUserStream, listUserChattedStream;
  String myName, myUsername, myEmail, myPhoneNumber, myProfilePic;
  String chatRoomId;

  // * Menampilkan data(user) ketika melakukan pencarian
  onSearchBtnClick() async {
    isSearching = true;
    listSearchUserStream =
        await DatabaseService().searchUserInDatabase(searchController.text);
    setState(() {});
  }

  Widget searchedUserWidget() {
    return StreamBuilder<QuerySnapshot>(
      stream: listSearchUserStream,
      builder: (context, snapshot) {
        return snapshot.hasData
            ? ListView.builder(
                shrinkWrap: true,
                itemCount: snapshot.data.docs.length,
                itemBuilder: (context, index) {
                  DocumentSnapshot ds = snapshot.data.docs[index];
                  return searchedUserWidgetTile(
                      userProfilePicSearched: ds["userProfilePic"],
                      userDisplayNameSearched: ds["userDisplayName"],
                      userEmailSearched: ds["userEmail"],
                      usernameSearched: ds["username"]);
                },
              )
            : Center(child: CircularProgressIndicator());
      },
    );
  }

  Widget searchedUserWidgetTile(
      {String userProfilePicSearched,
      String userDisplayNameSearched,
      String userEmailSearched,
      String usernameSearched}) {
    return GestureDetector(
      onTap: () {
        // * Membuat chatroomid jika belum tersedia
        chatRoomId = createChatRoomId(myUsername, usernameSearched);
        Map<String, dynamic> chatRoomIdInfoMap = {
          "users": [myUsername, usernameSearched]
        };
        DatabaseService().addChatRoomIdInfo(chatRoomId, chatRoomIdInfoMap);
        // *  ==========================================
        Get.to(ChatScreen(
          chatWithName: userDisplayNameSearched,
          chatWithUsername: usernameSearched,
          chatWithProfilePic: userProfilePicSearched,
        ));
      },
      child: Row(
        children: [
          Container(
            margin: EdgeInsets.symmetric(horizontal: 8, vertical: 16),
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              image: DecorationImage(
                image: NetworkImage(userProfilePicSearched),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(userDisplayNameSearched),
              Text(userEmailSearched),
            ],
          )
        ],
      ),
    );
  }
  // * ==============================================

  // * ini buat load data dari sharedpref dan juga buat chatroomid nya
  loadDataUserFromSharedPref() async {
    myUsername = await SharedPrefHelper().loadUsername();
    myName = await SharedPrefHelper().loadUserDisplayName();
    myEmail = await SharedPrefHelper().loadUserEmail();
    myPhoneNumber = await SharedPrefHelper().loadUserPhoneNumber();
    myProfilePic = await SharedPrefHelper().loadUserProfilePic();
  }

  String createChatRoomId(String a, String b) {
    if (a.substring(0, 1).codeUnitAt(0) <= b.substring(0, 1).codeUnitAt(0)) {
      return "$a\_$b";
    } else {
      return "$b\_$a";
    }
  }

  // * Menampilkan list user yang sudah ada di list
  getAndSetListUsers() async {
    listUserChattedStream = await DatabaseService().getListUser(myUsername);
    setState(() {});
  }

  Widget userChatted() {
    return StreamBuilder<QuerySnapshot>(
      stream: listUserChattedStream,
      builder: (context, snapshot) {
        return snapshot.hasData
            ? ListView.builder(
                shrinkWrap: true,
                physics: ClampingScrollPhysics(),
                itemCount: snapshot.data.docs.length,
                itemBuilder: (context, index) {
                  DocumentSnapshot ds = snapshot.data.docs[index];
                  return listUserChattedWidget(
                    chatWithName: ds.data()["chatWith"],
                    chatWithUsername:
                        ds.id.replaceAll(myUsername, "").replaceAll("_", ""),
                    chatWithProfilePic: ds.data()["profilePic"],
                    lastMessage: ds.data()["lastMessage"],
                  );
                },
              )
            : Container();
      },
    );
  }

  Widget listUserChattedWidget(
      {String chatWithName,
      String chatWithUsername,
      String chatWithProfilePic,
      String lastMessage}) {
    return GestureDetector(
      onTap: () {
        Get.to(ChatScreen(
          chatWithName: chatWithName,
          chatWithUsername: chatWithUsername,
          chatWithProfilePic: chatWithProfilePic,
        ));
      },
      child: Row(
        children: [
          Container(
            margin: EdgeInsets.symmetric(horizontal: 8, vertical: 16),
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              image: DecorationImage(
                image: NetworkImage(chatWithProfilePic),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(chatWithName),
              Text(lastMessage),
            ],
          )
        ],
      ),
    );
  }

  // * ===============================================
  doThisFirst() async {
    await loadDataUserFromSharedPref();
    getAndSetListUsers();
  }

  @override
  void initState() {
    super.initState();
    doThisFirst();
    isSearching = false;
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Home Screen",
          style: GoogleFonts.poppins(),
        ),
        actions: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: GestureDetector(
              onTap: () {
                AuthService().signOut();
              },
              child: Icon(Icons.logout),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Container(
          // width: MediaQuery.of(context).size.width,
          child: Column(
            children: [
              // * SEARCH BAR
              Row(
                children: [
                  isSearching
                      ? GestureDetector(
                          onTap: () {
                            searchController.text = "";
                            isSearching = false;
                            setState(() {});
                          },
                          child: Padding(
                              padding: EdgeInsets.symmetric(horizontal: 16),
                              child: Icon(Icons.arrow_back)),
                        )
                      : Container(),
                  Expanded(
                    child: TextField(
                      controller: searchController,
                      decoration: InputDecoration(
                        contentPadding: EdgeInsets.symmetric(horizontal: 16),
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      if (searchController.text != "") {
                        onSearchBtnClick();
                      }
                    },
                    child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        child: Icon(Icons.search)),
                  ),
                ],
              ),

              // * SHOW LIST USER
              isSearching ? searchedUserWidget() : userChatted(),
            ],
          ),
        ),
      ),
    );
  }
}
