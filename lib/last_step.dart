import 'dart:io';
import 'package:chit_chat/homepage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:image_picker/image_picker.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:path/path.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LastStep extends StatefulWidget {
  LastStep(this.response);
  final FirebaseUser response;

  @override
  _LastStepState createState() => _LastStepState();
}

class _LastStepState extends State<LastStep> {
  bool isuploaded = false;
  String name;
  bool loginindicator = false;
  String bio;
  String url;
  File croppedFile;
  var avatar;
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  final db = Firestore.instance;
  // final FirebaseAuth _auth = FirebaseAuth.instance;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  getprofilepicture() async {
    // FirebaseUser user = await FirebaseAuth.instance.currentUser();
    try {
      File image = await ImagePicker.pickImage(source: ImageSource.gallery);
      croppedFile = await ImageCropper.cropImage(
        sourcePath: image.path,
        aspectRatioPresets: [
          CropAspectRatioPreset.square,
        ],
        aspectRatio: CropAspectRatio(ratioX: 1, ratioY: 1),
        compressFormat: ImageCompressFormat.jpg,
        cropStyle: CropStyle.circle,
        maxHeight: 700,
        maxWidth: 700,
        compressQuality: 50,
        androidUiSettings: AndroidUiSettings(
            toolbarTitle: 'Crop Image',
            backgroundColor: ThemeData.dark().cardColor,
            toolbarColor: ThemeData.dark().cardColor,
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.original,
            hideBottomControls: true,
            showCropGrid: false,
            lockAspectRatio: true),
      );
      setState(() {
        avatar = croppedFile;
        isuploaded = true;
      });
    } catch (e) {
      setState(() {
        isuploaded = false;
      });
    }
  }

  uploaduserdata() async {
    try {
      FirebaseUser user = await FirebaseAuth.instance.currentUser();
      String fileName = basename(croppedFile.path);
      StorageReference reference = FirebaseStorage.instance
          .ref()
          .child(user.email + '/profilePicture/' + fileName);
      StorageUploadTask uploadTask = reference.putFile(croppedFile);
      var dowurl = await (await uploadTask.onComplete).ref.getDownloadURL();
      setState(() {
        url = dowurl.toString();
      });
      if (user != null) {
        UserUpdateInfo userUpdateInfo = new UserUpdateInfo();
        userUpdateInfo.displayName = name;
        userUpdateInfo.photoUrl = url;
        user.updateProfile(userUpdateInfo);
      }

      await updatebio();
    } catch (e) {}
  }

  Future<void> updatebio() async {
    await db
        .collection('UserInfo')
        .document(widget.response.email.toString())
        .setData({
      'Bio': bio,
      'BirthDay': '',
      'Name': name,
      'PhotoUrl': url,
      'Email': widget.response.email,
      'Id': widget.response.uid,
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () => Future<bool>.value(false),
      child: Scaffold(
        key: _scaffoldKey,
        body: loginindicator
            ? SpinKitWave(
                color: Colors.white,
                type: SpinKitWaveType.center,
                size: 50,
              )
            : SingleChildScrollView(
                child: Stack(
                  children: <Widget>[
                    Container(
                      width: MediaQuery.of(context).size.width,
                      height: MediaQuery.of(context).size.height,
                      child: Image.asset("images/background.jpg",
                          fit: BoxFit.cover),
                    ),
                    Container(
                      padding: EdgeInsets.only(top: 30, left: 50, right: 50),
                      child: Column(
                        children: <Widget>[
                          Text(
                            "Last Step....",
                            style: TextStyle(
                                fontSize: 40,
                                fontFamily: "Lora",
                                fontStyle: FontStyle.italic),
                          ),
                          SizedBox(
                            height: 40,
                          ),
                          Stack(
                            children: <Widget>[
                              CircleAvatar(
                                radius: 100,
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(100),
                                  child: Hero(
                                      child: InkWell(
                                        splashColor: Colors.transparent,
                                        highlightColor: Colors.transparent,
                                        child: (avatar != null)
                                            ? Image.file(avatar)
                                            : Image.asset(
                                                "images/circular.png"),
                                        onTap: () async {
                                          await getprofilepicture();
                                        },
                                      ),
                                      tag: "Hero"),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(
                            height: 20,
                          ),
                          Form(
                              key: _formKey,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  TextFormField(
                                    keyboardType: TextInputType.text,
                                    onSaved: (value) => name = value,
                                    maxLines: 1,
                                    validator: (value) {
                                      if (value.length != 0) {
                                        return null;
                                      } else {
                                        return "This Can't be Blank";
                                      }
                                    },
                                    decoration: InputDecoration(
                                      errorStyle: TextStyle(
                                          fontSize: 18,
                                          fontFamily: "Rosemary",
                                          color: ThemeData.dark().accentColor),
                                      border: InputBorder.none,
                                      hintText: "Name",
                                      icon: Icon(MdiIcons.account),
                                    ),
                                    style: TextStyle(
                                        fontSize: 23, fontFamily: "Jost"),
                                  ),
                                  Container(
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(20),
                                        border: Border.all(
                                          color: Colors.white,
                                        )),
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: TextFormField(
                                        keyboardType: TextInputType.text,
                                        onSaved: (val) => bio = val,
                                        // maxLength: 50,
                                        // maxLengthEnforced: true,
                                        validator: (value) {
                                          if (value.isEmpty) {
                                            return "This Can't be Blank";
                                          } else {
                                            return null;
                                          }
                                        },
                                        maxLines: 4,
                                        decoration: InputDecoration(
                                            errorStyle: TextStyle(
                                                fontSize: 18,
                                                fontFamily: "Rosemary",
                                                color: ThemeData.dark()
                                                    .accentColor),
                                            hintText: "Status/Bio",
                                            border: InputBorder.none),
                                        style: TextStyle(
                                            fontSize: 23, fontFamily: "Jost"),
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    height: 20,
                                  ),
                                  RaisedButton(
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(20)),
                                    onPressed: () async {
                                      final form = _formKey.currentState;
                                      if (isuploaded == true) {
                                        if (form.validate()) {
                                          setState(() {
                                            loginindicator = true;
                                          });
                                          form.save();
                                          await uploaduserdata();
                                          Navigator.of(context).push(
                                            MaterialPageRoute(
                                              builder: (BuildContext context) =>
                                                  Homepage(widget.response),
                                            ),
                                          );
                                        } else {
                                          print("noo");
                                        }
                                      } else {
                                        _scaffoldKey.currentState
                                            .showSnackBar(SnackBar(
                                          content: Text(
                                              "Profile Picture is Not Selected..",
                                              style: TextStyle(
                                                  fontFamily: "Rosemary",
                                                  fontSize: 18,
                                                  color: Colors.white)),
                                          backgroundColor: Colors.black,
                                        ));
                                      }
                                    },
                                    color: Colors.black,
                                    child: Text(
                                      "Continue..",
                                      style: TextStyle(
                                          fontSize: 22,
                                          fontFamily: "Rosemary",
                                          color: Colors.white),
                                    ),
                                  ),
                                ],
                              )),
                        ],
                      ),
                    )
                  ],
                ),
              ),
      ),
    );
  }
}
