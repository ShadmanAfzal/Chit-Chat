import 'package:password_strength/password_strength.dart';
import 'package:chit_chat/last_step.dart';
import 'package:email_validator/email_validator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

// import 'homepage.dart';

class Register extends StatefulWidget {
  Register({Key key}) : super(key: key);

  @override
  _RegisterState createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  bool isvisible = false;
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  final TextEditingController emailcontroller = new TextEditingController();
  final TextEditingController passwordcontroller = new TextEditingController();
  String _email;
  bool loginindicator = false;
  String _password;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  Future<void> register() async {
    try {
      final FirebaseUser user = (await _auth.createUserWithEmailAndPassword(
        email: _email,
        password: _password,
      ))
          .user;
      emailcontroller.clear();
      passwordcontroller.clear();
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (BuildContext context) => LastStep(user),
        ),
      );
    } catch (e) {
      setState(() {
        loginindicator = false;
      });
      _scaffoldKey.currentState.showSnackBar(SnackBar(
          content: Text(
            "User Already Register...",
            style: TextStyle(
                fontFamily: "Rosemary", fontSize: 18, color: Colors.white),
          ),
          backgroundColor: Colors.black));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                    child:
                        Image.asset("images/background.jpg", fit: BoxFit.cover),
                  ),
                  Container(
                    padding: EdgeInsets.only(top: 30, left: 50, right: 50),
                    child: Column(
                      children: <Widget>[
                        Text(
                          "Register",
                          style: TextStyle(
                            fontSize: 40,
                            fontFamily: "Lora",
                          ),
                        ),
                        SizedBox(
                          height: 60,
                        ),
                        CircleAvatar(
                          radius: 100,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(100),
                            child: Hero(
                                child: Image.asset("images/circular.png"),
                                tag: "xyz"),
                          ),
                        ),
                        SizedBox(
                          height: 40,
                        ),
                        Form(
                            key: _formKey,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                TextFormField(
                                  keyboardType: TextInputType.emailAddress,
                                  onSaved: (value) => _email = value,
                                  controller: emailcontroller,
                                  maxLines: 1,
                                  validator: (value) {
                                    if (EmailValidator.validate(value)) {
                                      return null;
                                    } else {
                                      return "Enter Valid Email Address";
                                    }
                                  },
                                  decoration: InputDecoration(
                                    errorStyle: TextStyle(
                                        fontSize: 18,
                                        fontFamily: "Rosemary",
                                        color: ThemeData.dark().accentColor),
                                    border: InputBorder.none,
                                    hintText: "Email Id",
                                    icon: Icon(MdiIcons.email),
                                  ),
                                  style: TextStyle(
                                      fontSize: 23, fontFamily: "Jost"),
                                ),
                                TextFormField(
                                  keyboardType: TextInputType.visiblePassword,
                                  obscureText: isvisible ? false : true,
                                  controller: passwordcontroller,
                                  onSaved: (val) => _password = val,
                                  validator: (value) {
                                    if (estimatePasswordStrength(value) <=
                                        0.3) {
                                      return "Your Password is Weak....";
                                    } else {
                                      return null;
                                    }
                                  },
                                  maxLines: 1,
                                  decoration: InputDecoration(
                                    suffixIcon: GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          isvisible = !isvisible;
                                        });
                                      },
                                      child: Icon(
                                        MdiIcons.eye,
                                        color: Colors.white,
                                        size: 30,
                                      ),
                                    ),
                                    errorStyle: TextStyle(
                                        fontSize: 18,
                                        fontFamily: "Rosemary",
                                        color: ThemeData.dark().accentColor),
                                    border: InputBorder.none,
                                    hintText: "Password",
                                    icon: Icon(MdiIcons.lock),
                                  ),
                                  style: TextStyle(
                                      fontSize: 23, fontFamily: "Jost"),
                                ),
                                SizedBox(
                                  height: 50,
                                ),
                                RaisedButton(
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20)),
                                  onPressed: () async {
                                    final form = _formKey.currentState;
                                    if (form.validate()) {
                                      form.save();
                                      setState(() {
                                        loginindicator = true;
                                      });
                                      await register();
                                    } else {
                                      print("noo");
                                    }
                                  },
                                  color: Colors.black,
                                  child: Padding(
                                    padding: const EdgeInsets.all(5.0),
                                    child: Text(
                                      "Register",
                                      style: TextStyle(
                                          fontSize: 25,
                                          fontFamily: "Rosemary",
                                          color: Colors.white),
                                    ),
                                  ),
                                ),
                              ],
                            )),
                      ],
                    ),
                  ),
                  Container(
                      child: Column(
                    children: <Widget>[
                      SizedBox(
                        height: 40,
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 15.0),
                        child: InkWell(
                          splashColor: Colors.transparent,
                          highlightColor: Colors.transparent,
                          child: Icon(
                            Icons.arrow_back,
                            size: 30,
                          ),
                          onTap: () {
                            Navigator.of(context).pop();
                          },
                        ),
                      ),
                    ],
                  )),
                ],
              ),
            ),
    );
  }
}
