import 'package:chit_chat/main.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'my_account.dart';
import 'Settings.dart';
import 'dart:async';
import 'package:bubble/bubble.dart';
import 'package:chit_chat/userprofile.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:image_downloader/image_downloader.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'dart:math';
import 'package:image_picker/image_picker.dart';

class ChatPage extends StatefulWidget {
  ChatPage(this.response, this.peerid, this.peerName, this.image);
  final String image;
  final FirebaseUser response;
  var peerid;
  var peerName;

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool showEmojiPicker = false;
  String groupChatId;
  bool isloading = true;
  String msg;
  double fontsize;
  String profileimg;
  Firestore _firestore = Firestore.instance;
  TextEditingController messageController = TextEditingController();
  ScrollController scrollController = ScrollController();
  String background;

  uploadmsgimg() async {
    File image = await ImagePicker.pickImage(
        source: ImageSource.gallery, imageQuality: 50);
    String fileName = basename(image.path);
    StorageReference reference =
        FirebaseStorage.instance.ref().child("message" + fileName);
    StorageUploadTask uploadTask = reference.putFile(image);
    var dowurl = await (await uploadTask.onComplete).ref.getDownloadURL();
    String url = dowurl.toString();
    await _firestore
        .collection('Messages')
        .document(groupChatId)
        .collection(groupChatId)
        .add({
      'from': widget.response.displayName,
      'messages': "msg",
      'to': widget.peerName,
      'time': FieldValue.serverTimestamp(),
      'type': "image",
      'url': url,
      'from_email': widget.response.email
    });
  }

  Future<void> loadassests() async {
    profileimg = widget.image;
    setState(() {
      isloading = false;
    });
  }

  getbackground() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    print(prefs.get("background"));
    setState(() {
      background = prefs.get("background");
      if (prefs.getDouble("fontsize") != null) {
        fontsize = prefs.getDouble("fontsize");
      } else {
        fontsize = 18;
      }
    });
  }

  @override
  void initState() {
    getbackground();
    if (widget.response.uid.hashCode <= widget.peerid.hashCode) {
      groupChatId = "${widget.response.uid}-${widget.peerid}";
    } else {
      groupChatId = "${widget.peerid}-${widget.response.uid}";
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            GestureDetector(
              onTap: () {
                Navigator.of(context).push(
                  CupertinoPageRoute(
                    builder: (_) => UserProfile(widget.peerid, widget.image),
                  ),
                );
              },
              child: CircleAvatar(
                radius: 23,
                child: ClipRRect(
                    borderRadius: BorderRadius.circular(100),
                    child: widget.image != null
                        ? CachedNetworkImage(imageUrl: widget.image)
                        : Container()),
              ),
            ),
            SizedBox(
              width: 10,
            ),
            Text(
              widget.peerName,
              style: TextStyle(fontFamily: "Rosemary", fontSize: 25),
            ),
          ],
        ),
        actions: <Widget>[
          PopupMenuButton<int>(
            elevation: 10,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            itemBuilder: (_) => [
              PopupMenuItem(
                value: 1,
                textStyle: TextStyle(fontFamily: "Rosemary", fontSize: 18),
                child: Text("Chat Settings"),
              ),
              PopupMenuItem(
                value: 2,
                textStyle: TextStyle(fontFamily: "Rosemary", fontSize: 18),
                child: Text("My Account"),
              ),
              PopupMenuItem(
                value: 3,
                textStyle: TextStyle(fontFamily: "Rosemary", fontSize: 18),
                child: Text("Logout"),
              )
            ],
            onSelected: (value) async {
              if (value == 1) {
                Navigator.of(context)
                    .push(CupertinoPageRoute(builder: (_) => Settings()));
              } else if (value == 2) {
                Navigator.of(context).push(
                  CupertinoPageRoute(
                    builder: (_) => Myaccount(widget.response),
                  ),
                );
              } else if (value == 3) {
                await _auth.signOut();
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (BuildContext context) => LoginPage()));
                ;
              }
            },
            // enabled: true,
          )
        ],
        elevation: 10,
      ),
      body: Stack(
        children: <Widget>[
          if (background == null)
            Image.asset(
              "images/background.jpg",
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,
              fit: BoxFit.cover,
            )
          else
            Image.file(
              File(background),
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,
              fit: BoxFit.cover,
            ),
          Container(
            child: Container(
              child: Column(
                children: <Widget>[
                  Expanded(
                    child: StreamBuilder<QuerySnapshot>(
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return Center(
                              child: SpinKitCircle(
                            color: Colors.white,
                            size: 100,
                          ));
                        } else {
                          List<DocumentSnapshot> docs = snapshot.data.documents;
                          Iterable<Messages> messages = docs
                              .map(
                                (doc) => Messages(
                                  from: doc.data['from'],
                                  msg: doc.data['messages'],
                                  me: widget.response.email ==
                                      doc.data['from_email'],
                                  type: doc.data['type'],
                                  url: doc.data['url'],
                                  from_email: doc.data['from_email'],
                                  fontsize: fontsize,
                                ),
                              )
                              .toList()
                              .reversed;

                          return ListView(
                            reverse: true,
                            // shrinkWrap: true,
                            controller: scrollController,
                            children: <Widget>[...messages],
                          );
                        }
                      },
                      stream: _firestore
                          .collection("Messages")
                          .document(groupChatId)
                          .collection(groupChatId)
                          .orderBy('time', descending: false)
                          .snapshots(),
                    ),
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  Container(
                      child: Row(
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 5.0),
                        child: GestureDetector(
                          onTap: () async {
                            uploadmsgimg();
                          },
                          child: CircleAvatar(
                            radius: 25,
                            backgroundColor: Colors.black,
                            child: Icon(
                              Icons.camera_alt,
                              color: Colors.white,
                              size: 30,
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(
                              left: 5.0, top: 8.0, right: 8.0, bottom: 8.0),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.black,
                              borderRadius: BorderRadius.circular(15),
                              border: Border.all(
                                  color: ThemeData.dark().cardColor, width: 2),
                            ),
                            child: Stack(
                              children: <Widget>[
                                Padding(
                                  padding: const EdgeInsets.only(left: 10.0),
                                  child: Container(
                                    child: TextField(
                                      controller: messageController,
                                      style: TextStyle(
                                          fontFamily: "Rosemary", fontSize: 20),
                                      cursorColor: Colors.white,
                                      decoration: InputDecoration(
                                          border: InputBorder.none,
                                          hintText: "Type your Message... ",
                                          suffixIcon: InkWell(
                                              splashColor: Colors.transparent,
                                              highlightColor:
                                                  Colors.transparent,
                                              child: Icon(
                                                Icons.send,
                                                color: Colors.white,
                                                size: 30,
                                              ),
                                              onTap: () async {
                                                if (messageController
                                                        .text.length >
                                                    0) {
                                                  setState(() {
                                                    msg =
                                                        messageController.text;
                                                  });

                                                  messageController.clear();
                                                  await _firestore
                                                      .collection('Messages')
                                                      .document(groupChatId)
                                                      .collection(groupChatId)
                                                      .add({
                                                    'from': widget
                                                        .response.displayName,
                                                    'messages': msg,
                                                    'to': widget.peerName,
                                                    'time': FieldValue
                                                        .serverTimestamp(),
                                                    'type': "text",
                                                    'url': "123",
                                                    'from_email':
                                                        widget.response.email
                                                  });
                                                  scrollController.animateTo(
                                                      scrollController.position
                                                          .minScrollExtent,
                                                      duration: Duration(
                                                          milliseconds: 300),
                                                      curve: Curves.easeOut);
                                                }
                                              }),
                                          labelStyle: TextStyle(
                                              fontFamily: "Rosemary",
                                              fontSize: 25,
                                              color: Colors.white)),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ))
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class Messages extends StatelessWidget {
  final String from;
  final String msg;
  final bool me;
  final String type;
  final String url;
  final from_email;
  final double fontsize;

  const Messages(
      {Key key,
      this.from,
      this.msg,
      this.me,
      this.type,
      this.url,
      this.from_email,
      this.fontsize})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment:
          me ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(left: 8.0, bottom: 15, right: 8.0),
          child: type == 'image'
              ? GestureDetector(
                  onLongPress: () async {
                    try {
                      int rand = Random().nextInt(10000);
                      await ImageDownloader.downloadImage(url,
                          destination: AndroidDestinationType.custom(
                              directory: "Chit Chat")
                            ..subDirectory("Media/$rand.png"));
                      Scaffold.of(context).showSnackBar(SnackBar(
                        content: Text(
                          "Message Download",
                          style: TextStyle(
                              fontFamily: "Rosemary",
                              fontSize: 18,
                              color: Colors.white),
                        ),
                        backgroundColor: Colors.black,
                      ));
                    } catch (error) {
                      print(error);
                    }
                  },
                  child: Material(
                    borderRadius: BorderRadius.circular(15),
                    elevation: 5,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(15),
                      child: CachedNetworkImage(
                        imageUrl: url,
                        height: 300,
                        width: 300,
                        fit: BoxFit.fill,
                      ),
                    ),
                  ))
              : Bubble(
                  elevation: 10,
                  margin: BubbleEdges.only(top: 10),
                  nip: me ? BubbleNip.rightTop : BubbleNip.leftTop,
                  color: me ? Colors.black : ThemeData.dark().cardColor,
                  child: SelectableText(
                    msg,
                    showCursor: false,
                    toolbarOptions: ToolbarOptions(copy: true, selectAll: true),
                    style: TextStyle(
                      fontFamily: "Rosemary",
                      fontSize: fontsize,
                    ),
                  ),
                ),
        ),
      ],
    );
  }
}
