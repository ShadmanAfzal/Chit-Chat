import 'package:cached_network_image/cached_network_image.dart';
import 'package:chit_chat/chat.dart';
import 'package:chit_chat/my_account.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class SearchUser extends StatefulWidget {
  SearchUser(this.response);
  final FirebaseUser response;

  @override
  _SearchUserState createState() => _SearchUserState();
}

class _SearchUserState extends State<SearchUser> {
  bool isloading = false;
  TextEditingController _searchController = TextEditingController();
  final db = Firestore.instance;
  String user;
  QuerySnapshot userqueryset;
  searchuser() async {
    await db
        .collection('UserInfo')
        .where('Name', isEqualTo: _searchController.text)
        .getDocuments()
        .then((value) {
      setState(() {
        userqueryset = value;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          "Search",
          style: TextStyle(fontFamily: "Rosemary", fontSize: 25),
        ),
      ),
      body: Stack(
        children: <Widget>[
          SingleChildScrollView(
            child: Container(
              child: Column(
                children: <Widget>[
                  Container(
                    height: 70,
                    color: ThemeData.dark().cardColor,
                    child: Row(
                      children: <Widget>[
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(left: 0.0),
                            child: TextField(
                              controller: _searchController,
                              style: TextStyle(
                                  fontFamily: "Rosemary", fontSize: 20),
                              decoration: InputDecoration(
                                hintText: "Search the User",
                                border: InputBorder.none,
                                prefixIcon: Icon(
                                  Icons.verified_user,
                                  size: 30,
                                  color: Colors.white,
                                ),
                                suffixIcon: InkWell(
                                  splashColor: Colors.transparent,
                                  highlightColor: Colors.transparent,
                                  onTap: () async {
                                    await searchuser();
                                    setState(() {
                                      user = "123";
                                    });
                                  },
                                  child: Icon(
                                    Icons.search,
                                    size: 35,
                                    color: Colors.white,
                                  ),
                                ),
                                hintStyle: TextStyle(
                                    fontFamily: "Rosemary", fontSize: 18),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 10),
                  userqueryset == null
                      ? Container()
                      : userqueryset.documents.length != 0
                          ? ListView.builder(
                              itemBuilder: (context, index) {
                                if (userqueryset.documents.length != 0) {
                                  return Container(
                                      color: ThemeData.dark().cardColor,
                                      child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: <Widget>[
                                                Row(
                                                  children: <Widget>[
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              left: 8.0),
                                                      child: CircleAvatar(
                                                        radius: 30,
                                                        child: ClipRRect(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      100),
                                                          child: CachedNetworkImage(
                                                              imageUrl: userqueryset
                                                                      .documents[
                                                                          index]
                                                                      .data[
                                                                  'PhotoUrl']),
                                                        ),
                                                      ),
                                                    ),
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              left: 5.0),
                                                      child: Text(
                                                        userqueryset
                                                            .documents[index]
                                                            .data['Name'],
                                                        style: TextStyle(
                                                            fontSize: 20,
                                                            fontFamily:
                                                                "Rosemary"),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          right: 12.0),
                                                  child: userqueryset
                                                              .documents[index]
                                                              .data['Id'] ==
                                                          widget.response.uid
                                                      ? RaisedButton(
                                                          shape:
                                                              RoundedRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        20),
                                                          ),
                                                          color: Colors.amber,
                                                          onPressed: () {
                                                            Navigator.of(
                                                                    context)
                                                                .push(
                                                              CupertinoPageRoute(
                                                                builder: (_) =>
                                                                    Myaccount(widget
                                                                        .response),
                                                              ),
                                                            );
                                                          },
                                                          child: Text(
                                                            "Go To Profile",
                                                            style: TextStyle(
                                                                fontSize: 20,
                                                                fontFamily:
                                                                    "Rosemary"),
                                                          ),
                                                        )
                                                      : RaisedButton(
                                                          color: Colors.blue,
                                                          child: Text(
                                                            "Message",
                                                            style: TextStyle(
                                                                fontSize: 20,
                                                                fontFamily:
                                                                    "Rosemary"),
                                                          ),
                                                          shape:
                                                              RoundedRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        20),
                                                          ),
                                                          onPressed: () async {
                                                            setState(() {
                                                              isloading = true;
                                                            });
                                                            await db
                                                                .collection(
                                                                    "UserInfo")
                                                                .document(widget
                                                                    .response
                                                                    .email)
                                                                .collection(
                                                                    "Message Send")
                                                                .document(userqueryset
                                                                    .documents[
                                                                        index]
                                                                    .data['Id'])
                                                                .setData(
                                                              {
                                                                "Id": widget
                                                                    .response
                                                                    .uid,
                                                                "Name": userqueryset
                                                                    .documents[
                                                                        index]
                                                                    .data['Name'],
                                                                "Time": FieldValue
                                                                    .serverTimestamp(),
                                                                "Image": userqueryset
                                                                        .documents[
                                                                            index]
                                                                        .data[
                                                                    'PhotoUrl'],
                                                                "friendId": userqueryset
                                                                    .documents[
                                                                        index]
                                                                    .data['Id']
                                                              },
                                                            );
                                                            await db
                                                                .collection(
                                                                    "UserInfo")
                                                                .document(userqueryset
                                                                        .documents[
                                                                            index]
                                                                        .data[
                                                                    'Email'])
                                                                .collection(
                                                                    "Message Send")
                                                                .document(widget
                                                                    .response
                                                                    .uid)
                                                                .setData(
                                                              {
                                                                "Id": userqueryset
                                                                    .documents[
                                                                        index]
                                                                    .data['Id'],
                                                                "Name": widget
                                                                    .response
                                                                    .displayName,
                                                                "Time": FieldValue
                                                                    .serverTimestamp(),
                                                                "Image": widget
                                                                    .response
                                                                    .photoUrl,
                                                                "friendId":
                                                                    widget
                                                                        .response
                                                                        .uid,
                                                              },
                                                            );

                                                            setState(() {
                                                              isloading = false;
                                                            });
                                                            Navigator.of(
                                                                    context)
                                                                .push(
                                                              CupertinoPageRoute(
                                                                builder: (BuildContext
                                                                        context) =>
                                                                    ChatPage(
                                                                  widget
                                                                      .response,
                                                                  userqueryset
                                                                      .documents[
                                                                          index]
                                                                      .data["Id"],
                                                                  userqueryset
                                                                      .documents[
                                                                          index]
                                                                      .data["Name"],
                                                                  userqueryset
                                                                      .documents[
                                                                          index]
                                                                      .data["Image"],
                                                                ),
                                                              ),
                                                            );
                                                          },
                                                        ),
                                                ),
                                              ],
                                            ),
                                            SizedBox(
                                              height: 10,
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  left: 8.0),
                                              child: Text(
                                                userqueryset.documents[index]
                                                    .data['Bio'],
                                                style: TextStyle(
                                                    fontSize: 20,
                                                    fontFamily: "Rosemary"),
                                              ),
                                            ),
                                            SizedBox(
                                              height: 20,
                                            )
                                          ]));
                                } else {
                                  return Container();
                                }
                              },
                              shrinkWrap: true,
                              itemCount: userqueryset.documents.length)
                          : Container(
                              child: Text(
                              "No user Found...",
                              style: TextStyle(
                                  fontFamily: "Rosemary", fontSize: 22),
                            ))
                ],
              ),
            ),
          ),
          Container(
              child: isloading
                  ? SpinKitCircle(
                      color: Colors.white,
                    )
                  : Center())
        ],
      ),
    );
  }
}
