import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class UserProfile extends StatefulWidget {
  UserProfile(this.id, this.image);
  final String image;
  final String id;

  @override
  _UserProfileState createState() => _UserProfileState();
}

class _UserProfileState extends State<UserProfile> {
  final db = Firestore.instance;
  bool isloaded = false;
  TextEditingController _biocontroller = TextEditingController();
  TextEditingController _namecontroller = TextEditingController();
  TextEditingController _emailcontroller = TextEditingController();
  TextEditingController _birthday = TextEditingController();

  Future<void> getuserdetails() async {
    await db
        .collection("UserInfo")
        .where("Id", isEqualTo: widget.id)
        .getDocuments()
        .then((value) {
      _biocontroller.text = value.documents[0].data["Bio"];
      _namecontroller.text = value.documents[0].data["Name"];
      _emailcontroller.text = value.documents[0].data["Email"];
      _birthday.text = value.documents[0].data["BirthDay"];
      setState(() {
        isloaded = true;
      });
    });
  }

  @override
  void initState() {
    getuserdetails();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        // appBar: AppBar(
        //   title: Text(
        //     _namecontroller.text,
        //     style: TextStyle(fontFamily: "Rosemary", fontSize: 22),
        //   ),
        // ),
        body: Stack(
      children: <Widget>[
        Container(
            child: !isloaded
                ? SpinKitCircle(
                    color: Colors.white,
                  )
                : CustomScrollView(
                    slivers: <Widget>[
                      SliverAppBar(
                        elevation: 10,
                        floating: true,
                        centerTitle: true,
                        title: Text(
                          _namecontroller.text,
                          style:
                              TextStyle(fontFamily: "Rosemary", fontSize: 22),
                        ),
                        expandedHeight: 350,
                        // forceElevated: true,
                        flexibleSpace: FlexibleSpaceBar(
                          background: CachedNetworkImage(
                            imageUrl: widget.image,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      SliverList(
                          delegate: SliverChildListDelegate([
                        Container(
                          child: Container(
                            child: Column(
                              children: <Widget>[
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 5.0),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: <Widget>[
                                      SizedBox(
                                        height: 15,
                                      ),
                                      Material(
                                        // elevation: 10,
                                        borderRadius: BorderRadius.circular(15),
                                        child: Card(
                                          elevation: 10,
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(15),
                                          ),
                                          child: Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Container(
                                              // height: 10,
                                              // elevation: 10,
                                              child: TextField(
                                                controller: _namecontroller,

                                                // enableInteractiveSelection: true,

                                                readOnly: true,

                                                style: TextStyle(
                                                    fontFamily: "Rosemary",
                                                    fontSize: 22),

                                                maxLines: 1,

                                                decoration: InputDecoration(
                                                  border: InputBorder.none,
                                                  labelText: "Name",
                                                  labelStyle: TextStyle(
                                                      fontFamily: "Rosemary",
                                                      fontSize: 25,
                                                      color: Colors.amber),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      Card(
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(15),
                                        ),
                                        elevation: 10,
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Container(
                                            child: TextField(
                                              controller: _emailcontroller,
                                              readOnly: true,
                                              style: TextStyle(
                                                  fontFamily: "Rosemary",
                                                  fontSize: 22),
                                              maxLines: 1,
                                              decoration: InputDecoration(
                                                border: InputBorder.none,
                                                labelText: "Email",
                                                labelStyle: TextStyle(
                                                    fontFamily: "Rosemary",
                                                    fontSize: 25,
                                                    color: Colors.amber),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      Card(
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(15),
                                        ),
                                        elevation: 10,
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: TextField(
                                            controller: _birthday,
                                            readOnly: true,
                                            style: TextStyle(
                                                fontFamily: "Rosemary",
                                                fontSize: 22),
                                            maxLines: 1,
                                            decoration: InputDecoration(
                                              border: InputBorder.none,
                                              labelText: "BirthDay",
                                              labelStyle: TextStyle(
                                                  fontFamily: "Rosemary",
                                                  fontSize: 25,
                                                  color: Colors.amber),
                                            ),
                                          ),
                                        ),
                                      ),
                                      Card(
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(15),
                                        ),
                                        elevation: 10,
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: TextField(
                                            controller: _biocontroller,
                                            readOnly: true,
                                            style: TextStyle(
                                                fontFamily: "Rosemary",
                                                fontSize: 22),
                                            maxLines:
                                                (_biocontroller.text.length /
                                                        35)
                                                    .ceil(),
                                            decoration: InputDecoration(
                                              border: InputBorder.none,
                                              labelText: "Bio",
                                              labelStyle: TextStyle(
                                                  fontFamily: "Rosemary",
                                                  fontSize: 30,
                                                  color: Colors.amber),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                      ]))
                    ],
                  )),
      ],
    ));
  }
}
