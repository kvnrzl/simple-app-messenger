import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseService {
  // * Proses Sign In (SignIn)
  Future<void> addUserIntoDatabase(String userid, Map userInfoMap) async {
    return await FirebaseFirestore.instance
        .collection("users")
        .doc(userid)
        .set(userInfoMap);
  }

  // * Proses Cari User (Home)
  Future<Stream<QuerySnapshot>> searchUserInDatabase(
      String getSearchUsername) async {
    return FirebaseFirestore.instance
        .collection("users")
        .where("username", isEqualTo: getSearchUsername)
        .snapshots();
  }

  // * Proses Memasukkan Pesan Pada Database (ChatScreen)
  Future<void> addMessagetoDatabase(
      String chatRoomId, String messageId, Map messageInfoMap) async {
    return FirebaseFirestore.instance
        .collection("chatrooms")
        .doc(chatRoomId)
        .collection("chats")
        .doc(messageId)
        .set(messageInfoMap);
  }

  // * Proses Memasukkan Last Message Info Pada Database (ChatScreen)
  Future<void> addLastMessageInfoIntoDatabase(
      String chatRoomId, Map lastMessageInfoMap) async {
    return FirebaseFirestore.instance
        .collection("chatrooms")
        .doc(chatRoomId)
        .update(lastMessageInfoMap);
  }

  // * Proses Mengquery Pesan Pada Database (realtime -> snapshot) (ChatScreen)
  Future<Stream<QuerySnapshot>> getMessageFromDatabase(
      String chatRoomId) async {
    return FirebaseFirestore.instance
        .collection("chatrooms")
        .doc(chatRoomId)
        .collection("chats")
        .orderBy("timeStamp", descending: true)
        .snapshots();
  }

  // * Proses memasukkan roomdidInfo ke dalam database
  Future<void> addChatRoomIdInfo(
      String chatRoomId, Map chatRoomIdInfoMap) async {
    final snapshot = await FirebaseFirestore.instance
        .collection("chatrooms")
        .doc(chatRoomId)
        .get();

    if (snapshot.exists) {
      return true;
    } else {
      return FirebaseFirestore.instance
          .collection("chatrooms")
          .doc(chatRoomId)
          .set(chatRoomIdInfoMap);
    }
  }

  // * Proses menampilkan data user yang telah di chat
  Future<Stream<QuerySnapshot>> getListUser(String myUsername) async {
    return FirebaseFirestore.instance
        .collection("chatrooms")
        .orderBy("lastTimeStamp", descending: true)
        .where("users", arrayContains: myUsername)
        .snapshots();
  }
}
