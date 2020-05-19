import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:bubble/bubble.dart';

class Settings extends StatefulWidget {
  Settings({Key key}) : super(key: key);

  @override
  _SettingsState createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  File background;
  String _background;
  double fontSize;

  getbacground() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _background = prefs.get("background");
      if (prefs.getDouble("fontsize") != null) {
        fontSize = prefs.getDouble("fontsize");
      } else {
        fontSize = 18;
      }
    });
  }

  @override
  void initState() {
    getbacground();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          leading: GestureDetector(
            child: Icon(Icons.arrow_back),
            onTap: () {
              Phoenix.rebirth(context);
            },
          ),
          actions: <Widget>[
            PopupMenuButton<int>(
              elevation: 10,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15)),
              itemBuilder: (_) => [
                PopupMenuItem(
                  value: 1,
                  textStyle: TextStyle(fontFamily: "Rosemary", fontSize: 18),
                  child: Text("Default"),
                ),
              ],
              onSelected: (value) async {
                if (value == 1) {
                  SharedPreferences prefs =
                      await SharedPreferences.getInstance();
                  prefs.remove("background");
                  prefs.remove("fontsize");
                  await getbacground();
                }
              },
            )
          ],
          title: Text(
            "Chat Settings",
            style: TextStyle(fontFamily: "Rosemary", fontSize: 20),
          )),
      body: Container(
        child: Column(
          children: <Widget>[
            Container(
              height: MediaQuery.of(context).size.height / 6,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget>[
                  Text(
                    "Message Text Size",
                    style: TextStyle(fontFamily: "Rosemary", fontSize: 20),
                  ),
                  SliderTheme(
                    data: SliderThemeData(
                      thumbColor: Colors.white,
                      activeTrackColor: Colors.white,
                      overlayColor: Colors.grey,
                      inactiveTrackColor: Color(0xFF8D8E98),
                    ),
                    child: Slider(
                      value: fontSize,
                      onChanged: (value) async {
                        SharedPreferences prefs =
                            await SharedPreferences.getInstance();
                        prefs.setDouble("fontsize", value);
                        print(prefs.getDouble("fontsize"));
                        setState(
                          () {
                            fontSize = value;
                          },
                        );
                      },
                      min: 15,
                      divisions: 10,
                      max: 25,
                    ),
                  ),
                ],
              ),
            ),
            Column(
              children: <Widget>[
                Container(
                  height: MediaQuery.of(context).size.height / 2,
                  child: Stack(
                    children: <Widget>[
                      if (_background != null)
                        Image.file(
                          File(_background),
                          fit: BoxFit.cover,
                          height: MediaQuery.of(context).size.height,
                          width: MediaQuery.of(context).size.width,
                        )
                      else
                        (background == null)
                            ? Image.asset(
                                "images/background.jpg",
                                fit: BoxFit.cover,
                                height: MediaQuery.of(context).size.height,
                                width: MediaQuery.of(context).size.width,
                              )
                            : Image.file(
                                background,
                                fit: BoxFit.cover,
                                height: MediaQuery.of(context).size.height,
                                width: MediaQuery.of(context).size.width,
                              ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: <Widget>[
                          Bubble(
                            color: Colors.black,
                            alignment: Alignment.centerRight,
                            child: Text(
                              "“Hello John! How are you doing?”",
                              style: TextStyle(
                                  fontSize: fontSize, fontFamily: "Rosemary"),
                            ),
                            nip: BubbleNip.rightTop,
                          ),
                          Bubble(
                            color: ThemeData.dark().cardColor,
                            alignment: Alignment.centerLeft,
                            child: Text(
                              "I am good",
                              style: TextStyle(
                                  fontSize: fontSize, fontFamily: "Rosemary"),
                            ),
                            nip: BubbleNip.leftTop,
                          ),
                          Bubble(
                            color: Colors.black,
                            alignment: Alignment.centerRight,
                            child: Text(
                              "Perfect, I am really glad to hear that! How may I help you today?",
                              style: TextStyle(
                                  fontSize: fontSize, fontFamily: "Rosemary"),
                            ),
                            nip: BubbleNip.rightTop,
                          ),
                          Bubble(
                            color: ThemeData.dark().cardColor,
                            alignment: Alignment.centerLeft,
                            child: Text(
                              "“I am really sorry to hear that. Is there anything I can do to help you?”",
                              style: TextStyle(
                                  fontSize: fontSize, fontFamily: "Rosemary"),
                            ),
                            nip: BubbleNip.leftTop,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                alignment: Alignment.centerLeft,
                child: GestureDetector(
                  onTap: () async {
                    SharedPreferences prefs =
                        await SharedPreferences.getInstance();
                    File image = await ImagePicker.pickImage(
                        source: ImageSource.gallery);
                    prefs.setString("background", image.path);
                    getbacground();
                    setState(() {
                      background = image;
                    });
                  },
                  child: Text(
                    "Change Chat Background",
                    style: TextStyle(fontFamily: "Rosemary", fontSize: 22),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
