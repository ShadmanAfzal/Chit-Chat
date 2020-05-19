import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:path/path.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:image_cropper/image_cropper.dart';

class Myaccount extends StatefulWidget {
  Myaccount(this.response);
  final FirebaseUser response;

  @override
  _MyaccountState createState() => _MyaccountState();
}

class _MyaccountState extends State<Myaccount> {
  bool isloaded = false;
  DateTime birthday;
  String birth;
  String name;
  String image;
  File avatar;
  final db = Firestore.instance;
  TextEditingController namecontroller = TextEditingController();
  TextEditingController emailcontroller = TextEditingController();
  TextEditingController phonecontroller = TextEditingController();

  getbio() async {
    try {
      FirebaseUser _auth = await FirebaseAuth.instance.currentUser();
      namecontroller.text = _auth.displayName;
      var bd =
          await db.collection('UserInfo').document(widget.response.email).get();
      phonecontroller.text = bd.data['Bio'];
      if (birth == "") {
        setState(() {
          birth = "Enter Your BirthDay";
        });
      } else {
        setState(() {
          birth = bd.data['BirthDay'];
        });
      }
      image = widget.response.photoUrl;
      setState(() {
        isloaded = true;
      });
    } catch (e) {
      print(e);
    }
  }

  Future<void> updatebio() async {
    await db
        .collection('UserInfo')
        .document(widget.response.email)
        .updateData({'Bio': phonecontroller.text});
  }

  Future getImage() async {
    FirebaseUser user = await FirebaseAuth.instance.currentUser();
    File image = await ImagePicker.pickImage(source: ImageSource.gallery);
    File croppedFile = await ImageCropper.cropImage(
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
    });
    String fileName = basename(croppedFile.path);
    StorageReference reference = FirebaseStorage.instance
        .ref()
        .child(user.email + '/profilePicture/' + fileName);
    StorageUploadTask uploadTask = reference.putFile(croppedFile);
    var dowurl = await (await uploadTask.onComplete).ref.getDownloadURL();
    String url = dowurl.toString();
    if (user != null) {
      UserUpdateInfo userUpdateInfo = new UserUpdateInfo();
      userUpdateInfo.photoUrl = url;
      user.updateProfile(userUpdateInfo);
      print(user.photoUrl);
    }
    await db
        .collection('UserInfo')
        .document(widget.response.email)
        .updateData({'PhotoUrl': url});
    print(url);
  }

  @override
  void initState() {
    String name = widget.response.displayName.toString() == ""
        ? ""
        : widget.response.displayName;
    String email = widget.response.email == ""
        ? '"Enter Your Email"'
        : widget.response.email;
    getbio();
    namecontroller.text = name;
    emailcontroller.text = email;

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: !isloaded
          ? SpinKitCircle(
              color: Colors.white,
            )
          : Stack(
              children: <Widget>[
                Container(
                    child: CustomScrollView(
                  slivers: <Widget>[
                    SliverAppBar(
                      actions: <Widget>[
                        Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: InkWell(
                            splashColor: Colors.transparent,
                            highlightColor: Colors.transparent,
                            onTap: () async {
                              await getImage();
                              Phoenix.rebirth(context);
                            },
                            child: Icon(
                              Icons.file_upload,
                              size: 30,
                            ),
                          ),
                        )
                      ],
                      elevation: 20,
                      expandedHeight: 300,
                      flexibleSpace: FlexibleSpaceBar(
                        background: Hero(
                          child: (avatar != null)
                              ? Image.file(avatar, fit: BoxFit.cover)
                              : CachedNetworkImage(
                                  imageUrl: widget.response.photoUrl,
                                  fit: BoxFit.cover),
                          tag: "Hero",
                        ),
                      ),
                    ),
                    SliverList(
                      delegate: SliverChildListDelegate(
                        [
                          Padding(
                            padding: EdgeInsets.only(left: 2, right: 2, top: 5),
                            child: Material(
                              child: Card(
                                elevation: 10,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15)),
                                child: Container(
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: <Widget>[
                                      Container(
                                        child: Row(
                                          children: <Widget>[
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  left: 1.0, bottom: 4.0),
                                              child: Container(
                                                alignment: Alignment.topCenter,
                                                child: TextField(
                                                  controller: namecontroller,
                                                  // maxLength: 20,
                                                  maxLines: 1,
                                                  autocorrect: false,
                                                  cursorColor: Colors.white,
                                                  style: TextStyle(
                                                      fontFamily: "Rosemary",
                                                      fontSize: 20),
                                                  decoration: InputDecoration(
                                                      labelText: "Name",
                                                      labelStyle: TextStyle(
                                                          fontSize: 25),
                                                      prefixIcon: Icon(
                                                          MdiIcons.account,
                                                          color: Colors.white,
                                                          size: 35),
                                                      border: InputBorder.none),
                                                  enabled: false,
                                                ),
                                                width: MediaQuery.of(context)
                                                        .size
                                                        .width -
                                                    90,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.only(left: 2, right: 2, top: 0),
                            child: Material(
                              child: Card(
                                elevation: 10,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15)),
                                child: Container(
                                  height: 150,
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: <Widget>[
                                      Row(
                                        children: <Widget>[
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                left: 1.0, bottom: 4),
                                            child: Container(
                                              alignment: Alignment.topCenter,
                                              child: TextField(
                                                controller: phonecontroller,
                                                // maxLength: 10,
                                                maxLines: 10,
                                                autocorrect: false,
                                                cursorColor: Colors.white,
                                                keyboardType:
                                                    TextInputType.text,
                                                style: TextStyle(
                                                    fontFamily: "Rosemary",
                                                    fontSize: 20),
                                                decoration: InputDecoration(
                                                    labelText: "Bio",
                                                    labelStyle:
                                                        TextStyle(fontSize: 25),
                                                    prefixIcon: Icon(
                                                        MdiIcons.information,
                                                        color: Colors.white,
                                                        size: 35),
                                                    suffixIcon: InkWell(
                                                      splashColor:
                                                          Colors.transparent,
                                                      highlightColor:
                                                          Colors.transparent,
                                                      onTap: () async {
                                                        await updatebio();
                                                        Phoenix.rebirth(
                                                            context);
                                                      },
                                                      child: Icon(
                                                        MdiIcons.checkBold,
                                                        size: 30,
                                                      ),
                                                    ),
                                                    border: InputBorder.none),
                                              ),
                                              width: MediaQuery.of(context)
                                                      .size
                                                      .width -
                                                  20,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.only(left: 2, right: 2, top: 0),
                            child: Material(
                              child: Card(
                                elevation: 10,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15)),
                                child: Container(
                                  // height: ,
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: <Widget>[
                                      Row(
                                        children: <Widget>[
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                left: 2.0, bottom: 4),
                                            child: Container(
                                              alignment: Alignment.topCenter,
                                              child: TextField(
                                                controller: emailcontroller,
                                                readOnly: true,
                                                autocorrect: false,
                                                maxLines: 1,
                                                cursorColor: Colors.white,
                                                style: TextStyle(
                                                    fontFamily: "Rosemary",
                                                    fontSize: 20),
                                                decoration: InputDecoration(
                                                    labelText: "Email",
                                                    prefixIcon: Icon(
                                                      MdiIcons.email,
                                                      color: Colors.white,
                                                      size: 35,
                                                    ),
                                                    labelStyle: TextStyle(
                                                        fontFamily: "Rosemary",
                                                        fontSize: 25),
                                                    border: InputBorder.none),
                                              ),
                                              width: MediaQuery.of(context)
                                                      .size
                                                      .width -
                                                  90,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.only(left: 2, right: 2, top: 0),
                            child: Material(
                              child: InkWell(
                                splashColor: Colors.transparent,
                                highlightColor: Colors.transparent,
                                onTap: () {
                                  showDatePicker(
                                          context: context,
                                          initialDate: DateTime(2012),
                                          firstDate: DateTime(1900),
                                          lastDate: DateTime(2900))
                                      .then((date) async {
                                    setState(() {
                                      birthday = date;
                                    });
                                    await db
                                        .collection('UserInfo')
                                        .document(widget.response.email)
                                        .updateData({
                                      'BirthDay': DateFormat('dd-MM-yyyy')
                                          .format(birthday)
                                          .toString(),
                                    });
                                  });
                                },
                                child: Card(
                                  elevation: 10,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(15)),
                                  child: Container(
                                    height: 50,
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: <Widget>[
                                        Row(
                                          children: <Widget>[
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  left: 5.0, top: 5),
                                              child: Align(
                                                alignment: Alignment.topLeft,
                                                child: Icon(
                                                  Icons.date_range,
                                                  size: 35,
                                                ),
                                              ),
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  left: 1.0,
                                                  bottom: 4,
                                                  top: 10),
                                              child: Container(
                                                alignment: Alignment.topCenter,
                                                child: Text(
                                                  (birthday == null)
                                                      ? birth.toString()
                                                      : DateFormat('dd-MM-yyyy')
                                                          .format(birthday)
                                                          .toString(),
                                                  style: TextStyle(
                                                      fontFamily: "Rosemary",
                                                      fontSize: 20),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.only(left: 2, right: 2, top: 0),
                            child: Material(
                              child: InkWell(
                                splashColor: Colors.transparent,
                                highlightColor: Colors.transparent,
                                onLongPress: () {
                                  showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return AlertDialog(
                                          shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(15)),
                                          title: Text(
                                            "Delete Account",
                                            style: TextStyle(
                                                fontFamily: "Lora",
                                                fontSize: 22),
                                          ),
                                          content: Text(
                                            "Confirm ?",
                                            style: TextStyle(
                                                fontFamily: "Rosemary",
                                                fontSize: 20),
                                          ),
                                          actions: <Widget>[
                                            FlatButton(
                                                onPressed: () {
                                                  Navigator.of(context).pop();
                                                },
                                                child: Text(
                                                  "No",
                                                  style: TextStyle(
                                                      fontFamily: "Jost",
                                                      fontSize: 18),
                                                )),
                                            FlatButton(
                                                onPressed: () async {
                                                  FirebaseUser user =
                                                      await FirebaseAuth
                                                          .instance
                                                          .currentUser();
                                                  await user.delete();
                                                  Phoenix.rebirth(context);
                                                },
                                                child: Text(
                                                  "Yes",
                                                  style: TextStyle(
                                                      fontFamily: "Jost",
                                                      fontSize: 18),
                                                )),
                                          ],
                                        );
                                      });
                                },
                                child: Card(
                                  elevation: 10,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(15)),
                                  child: Container(
                                    height: 50,
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: <Widget>[
                                        Row(
                                          children: <Widget>[
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  left: 5.0, top: 5),
                                              child: Align(
                                                alignment: Alignment.topLeft,
                                                child: Icon(
                                                  Icons.delete_forever,
                                                  size: 35,
                                                ),
                                              ),
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  left: 1.0,
                                                  bottom: 4,
                                                  top: 10),
                                              child: Container(
                                                alignment: Alignment.topCenter,
                                                child: Text(
                                                  "Delete Account",
                                                  style: TextStyle(
                                                      fontFamily: "Rosemary",
                                                      fontSize: 20),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ))
              ],
            ),
    );
  }
}
