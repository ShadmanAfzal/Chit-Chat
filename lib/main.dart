import 'package:chit_chat/homepage.dart';
import 'package:chit_chat/register.dart';
import 'package:email_validator/email_validator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

void main() async {
  var home;
  WidgetsFlutterBinding.ensureInitialized();
  FirebaseUser firebaseUser = await FirebaseAuth.instance.currentUser();
  if (firebaseUser != null) {
    home = Homepage(firebaseUser);
  } else {
    home = LoginPage();
  }

  runApp(Phoenix(
    child: MaterialApp(
      title: "Chit Chat",
      home: home,
      theme: ThemeData.dark(),
      debugShowCheckedModeBanner: false,
    ),
  ));
}

class LoginPage extends StatefulWidget {
  LoginPage({Key key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController emailcontroller = new TextEditingController();
  final TextEditingController passwordcontroller = new TextEditingController();
  String _email;
  bool loginindicator = false;
  String _password;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  @override
  initState() {
    super.initState();
  }

  void showInSnackBar(String value) {
    _scaffoldKey.currentState.showSnackBar(
      SnackBar(
        backgroundColor: ThemeData.dark().snackBarTheme.backgroundColor,
        duration: Duration(seconds: 2),
        content: new Text(
          value,
          style: TextStyle(fontFamily: "Rosenary"),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _scaffoldKey.currentState.dispose();
    _formKey.currentState.dispose();
    super.dispose();
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
                      padding: EdgeInsets.only(top: 50, left: 50, right: 50),
                      child: Column(
                        children: <Widget>[
                          Text(
                            "Login",
                            style: TextStyle(
                                fontSize: 40,
                                fontFamily: "Lora",
                                fontStyle: FontStyle.italic),
                          ),
                          SizedBox(
                            height: 40,
                          ),
                          CircleAvatar(
                            radius: 100,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(100),
                              child: Hero(
                                  child: Image.asset("images/circular.png"),
                                  tag: "Hero"),
                            ),
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
                                    controller: emailcontroller,
                                    keyboardType: TextInputType.emailAddress,
                                    onSaved: (value) => _email = value,
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
                                    controller: passwordcontroller,
                                    keyboardType: TextInputType.visiblePassword,
                                    obscureText: true,
                                    onSaved: (val) => _password = val,
                                    validator: (value) {
                                      if (value.isEmpty) {
                                        return "Enter Password";
                                      } else {
                                        return null;
                                      }
                                    },
                                    maxLines: 1,
                                    decoration: InputDecoration(
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
                                    height: 20,
                                  ),
                                  RaisedButton(
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(20)),
                                    onPressed: () async {
                                      final form = _formKey.currentState;
                                      if (form.validate()) {
                                        form.save();
                                        setState(() {
                                          loginindicator = true;
                                        });
                                        await login();
                                      }
                                    },
                                    color: Colors.black,
                                    child: Padding(
                                      padding: const EdgeInsets.all(3.0),
                                      child: Text(
                                        "Login",
                                        style: TextStyle(
                                            fontSize: 25,
                                            fontFamily: "Rosemary",
                                            color: Colors.white),
                                      ),
                                    ),
                                  ),
                                  RaisedButton(
                                    onPressed: () {
                                      emailcontroller.clear();
                                      passwordcontroller.clear();
                                      Navigator.of(context).push(
                                          CupertinoPageRoute(
                                              builder: (BuildContext context) =>
                                                  Register()));
                                    },
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(20)),
                                    color: Colors.black,
                                    child: Padding(
                                      padding: const EdgeInsets.all(3.0),
                                      child: Text(
                                        "Register",
                                        style: TextStyle(
                                            fontSize: 25,
                                            fontFamily: "Rosemary",
                                            color: Colors.white),
                                      ),
                                    ),
                                  )
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

  Future<void> login() async {
    try {
      FirebaseUser user = (await FirebaseAuth.instance
              .signInWithEmailAndPassword(email: _email, password: _password))
          .user;
      passwordcontroller.clear();
      emailcontroller.clear();

      Navigator.of(context).push(
        CupertinoPageRoute(
          builder: (BuildContext context) => Homepage(user),
        ),
      );
    } catch (e) {
      setState(() {
        loginindicator = false;
      });
      _scaffoldKey.currentState.showSnackBar(
        SnackBar(
          backgroundColor: ThemeData.dark().cardColor,
          content: Text(
            "Email doesn't Exists or Password is incorrect..",
            style: TextStyle(
                fontFamily: "Rosemary", color: Colors.white, fontSize: 15),
          ),
        ),
      );
    }
  }
}
