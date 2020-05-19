import 'package:cached_network_image/cached_network_image.dart';
import 'package:chit_chat/main.dart';
import 'package:chit_chat/my_account.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'Settings.dart';

class Menu extends StatefulWidget {
  Menu(this.response);
  final FirebaseUser response;

  @override
  _MenuState createState() => _MenuState();
}

class _MenuState extends State<Menu> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String name = "Null";
  String image;
  getuser() async {
    FirebaseUser user = await FirebaseAuth.instance.currentUser();
    name = user.displayName;
    image = user.photoUrl;
    print(user.photoUrl);
  }

  @override
  void initState() {
    getuser();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(left: 10),
      child: Column(
        children: <Widget>[
          SizedBox(
            height: 50,
          ),
          Align(
            alignment: Alignment.topLeft,
            child: CircleAvatar(
              radius: 100,
              child: ClipRRect(
                  borderRadius: BorderRadius.circular(100),
                  child: CachedNetworkImage(
                    imageUrl: image,
                    fit: BoxFit.fill,
                  )),
            ),
          ),
          SizedBox(
            height: 20,
          ),
          Padding(
            padding: const EdgeInsets.only(left: 0.0),
            child: Align(
              alignment: Alignment.bottomLeft,
              child: Text(
                name,
                style: TextStyle(fontSize: 27, fontFamily: "Rosemary"),
              ),
            ),
          ),
          SizedBox(
            height: 70,
          ),
          Row(
            children: <Widget>[
              Icon(
                MdiIcons.account,
                size: 35,
              ),
              SizedBox(
                width: 5,
              ),
              InkWell(
                splashColor: Colors.transparent,
                highlightColor: Colors.transparent,
                onTap: () {
                  Navigator.of(context).push(CupertinoPageRoute(
                    builder: (BuildContext context) =>
                        Myaccount(widget.response),
                  ));
                },
                child: Text(
                  "My Account",
                  style: TextStyle(fontSize: 25, fontFamily: "Jost"),
                ),
              ),
            ],
          ),
          SizedBox(
            height: 10,
          ),
          Row(
            children: <Widget>[
              Icon(
                Icons.settings,
                size: 35,
              ),
              SizedBox(
                width: 5,
              ),
              InkWell(
                splashColor: Colors.transparent,
                highlightColor: Colors.transparent,
                onTap: () {
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (BuildContext context) => Settings(),
                  ));
                },
                child: Text(
                  "Settings",
                  style: TextStyle(fontSize: 25, fontFamily: "Jost"),
                ),
              ),
            ],
          ),
          SizedBox(
            height: 10,
          ),
          Container(
            child: Row(
              children: <Widget>[
                Icon(
                  MdiIcons.close,
                  size: 30,
                ),
                SizedBox(
                  width: 5,
                ),
                InkWell(
                  splashColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                  onTap: () async {
                    await _auth.signOut();

                    Navigator.of(context).push(CupertinoPageRoute(
                        builder: (BuildContext context) => LoginPage()));
                  },
                  child: Text(
                    "Logout",
                    style: TextStyle(fontSize: 25, fontFamily: "Jost"),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
