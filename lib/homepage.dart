import 'package:cached_network_image/cached_network_image.dart';
import 'package:chit_chat/chat.dart';
import 'package:chit_chat/searchuser.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'menu.dart';

class Homepage extends StatefulWidget {
  Homepage(this.response);
  final FirebaseUser response;

  @override
  _HomepageState createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> with TickerProviderStateMixin {
  bool iscollpased = false;
  bool showEmojiPicker = false;
  String avatar;
  AnimationController _scaleTransition;
  String msg;
  Animation<double> _scaleAnimation;

  Firestore _firestore = Firestore.instance;
  TextEditingController messageController = TextEditingController();
  ScrollController scrollController = ScrollController();
  FocusNode textfocus = FocusNode();
  final db = Firestore.instance;
  QuerySnapshot querySnapshot;
  showkeyboard() => textfocus.requestFocus();
  hidekeyboard() => textfocus.unfocus();
  hidemojikey() {
    setState(() {
      showEmojiPicker = false;
    });
  }

  showemoji() {
    setState(() {
      showEmojiPicker = true;
    });
  }

  getprofilepic() async {
    FirebaseUser userdata = await FirebaseAuth.instance.currentUser();
    setState(() {
      avatar = userdata.photoUrl;
    });
  }

  @override
  void initState() {
    getprofilepic();
    _scaleTransition =
        AnimationController(vsync: this, duration: Duration(milliseconds: 300));
    _scaleAnimation =
        Tween<double>(begin: 1, end: .9).animate(_scaleTransition);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    return WillPopScope(
      onWillPop: () => Future<bool>.value(false),
      child: Scaffold(
        floatingActionButton: FloatingActionButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => SearchUser(widget.response),
                ),
              );
            },
            child: Icon(
              Icons.search,
              size: 30,
              color: Colors.white,
            ),
            backgroundColor: Colors.black),
        body: SingleChildScrollView(
          physics: ScrollPhysics(),
          child: GestureDetector(
            onPanUpdate: (details) {
              if (details.delta.dx < 15 && iscollpased) {
                setState(() {
                  iscollpased = !iscollpased;
                  print("hello");
                });
                _scaleTransition.reverse();
              }
              if (details.delta.dx > 15 && !iscollpased) {
                setState(() {
                  iscollpased = !iscollpased;
                });
                _scaleTransition.forward();
              }
            },
            child: Stack(
              children: <Widget>[
                Image.asset(
                  "images/background.jpg",
                  height: MediaQuery.of(context).size.height,
                  width: MediaQuery.of(context).size.width,
                  fit: BoxFit.cover,
                ),
                Menu(widget.response),
                AnimatedPositioned(
                  top: iscollpased ? height / 4 : 0,
                  bottom: iscollpased ? height / 10 : 0,
                  left: iscollpased ? width / 1.8 : 0,
                  right: iscollpased ? -width / 1.8 : 0,
                  child: Material(
                    elevation: 10,
                    borderRadius: iscollpased
                        ? BorderRadius.circular(30)
                        : BorderRadius.circular(0),
                    child: ScaleTransition(
                      scale: _scaleAnimation,
                      child: Stack(
                        children: <Widget>[
                          Container(
                            child: Column(
                              children: <Widget>[
                                SizedBox(
                                  height: 25,
                                ),
                                Container(
                                  height: 50,
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(left: 8.0),
                                        child: InkWell(
                                          splashColor: Colors.transparent,
                                          highlightColor: Colors.transparent,
                                          child: AnimatedIcon(
                                            icon: AnimatedIcons.menu_close,
                                            progress: _scaleTransition,
                                            size: 30,
                                          ),
                                          onTap: () {
                                            if (iscollpased == true) {
                                              _scaleTransition.reverse();
                                            } else {
                                              _scaleTransition.forward();
                                            }
                                            setState(() {
                                              iscollpased = !iscollpased;
                                            });
                                          },
                                        ),
                                      ),
                                      Text(
                                        "Chit Chat",
                                        style: TextStyle(
                                            fontSize: 25, fontFamily: "Jost"),
                                      ),
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(right: 8.0),
                                        child: CircleAvatar(
                                          child: ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(100),
                                            child: CachedNetworkImage(
                                                imageUrl: avatar),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                StreamBuilder<QuerySnapshot>(
                                  builder: (_, snapshot) {
                                    if (!snapshot.hasData) {
                                      return Container();
                                    } else {
                                      return ListView.separated(
                                        itemBuilder: (_, int index) {
                                          return Container(
                                            decoration: BoxDecoration(),
                                            child: Material(
                                              child: ListTile(
                                                leading: CircleAvatar(
                                                  radius: 22,
                                                  child: ClipRRect(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            100),
                                                    child: CachedNetworkImage(
                                                      imageUrl: snapshot
                                                          .data
                                                          .documents[index]
                                                          .data['Image'],
                                                    ),
                                                  ),
                                                ),
                                                title: Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          left: 0.0),
                                                  child: Text(
                                                    snapshot
                                                        .data
                                                        .documents[index]
                                                        .data['Name'],
                                                    style: TextStyle(
                                                        fontFamily: "Rosemary",
                                                        fontSize: 25),
                                                  ),
                                                ),
                                                onTap: () {
                                                  Navigator.of(context).push(
                                                    CupertinoPageRoute(
                                                      builder: (_) => ChatPage(
                                                        widget.response,
                                                        snapshot
                                                            .data
                                                            .documents[index]
                                                            .data['friendId'],
                                                        snapshot
                                                            .data
                                                            .documents[index]
                                                            .data['Name'],
                                                        snapshot
                                                            .data
                                                            .documents[index]
                                                            .data['Image'],
                                                      ),
                                                    ),
                                                  );
                                                },
                                                // dense: true,
                                              ),
                                            ),
                                          );
                                        },
                                        separatorBuilder: (_, x) {
                                          return Divider(
                                            indent: 60,
                                            thickness: 2,
                                            endIndent: 10,
                                          );
                                        },
                                        shrinkWrap: true,
                                        itemCount:
                                            snapshot.data.documents.length,
                                      );
                                    }
                                  },
                                  stream: _firestore
                                      .collection("UserInfo")
                                      .document(widget.response.email)
                                      .collection("Message Send")
                                      .where("Id",
                                          isEqualTo: widget.response.uid)
                                      .orderBy('Time', descending: true)
                                      .snapshots(),
                                )
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  duration: Duration(milliseconds: 300),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
