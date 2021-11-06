import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:silkraod_store/globals.dart';
import 'package:silkraod_store/models/user.dart';

import 'firebase_fcm.dart';

class RegisterPage extends StatefulWidget {
  @override
  RegisterPageState createState() => RegisterPageState();
}

class RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  User _user;
  String _name, _mobile, _password;
  bool _isSubmitting = false, _obscureText = true;

  Widget _showTitle() {
    return Text('Register', style: Theme.of(context).textTheme.headline5);
  }

  Widget _showName() {
    return Padding(
        padding: EdgeInsets.only(top: 20.0),
        child: TextFormField(
            onSaved: (val) => _name = val,
            validator: (val) => val.length < 3 ? 'Name too short' : null,
            decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Name',
                hintText: 'Enter your name',
                icon: Icon(
                  Icons.people,
                  color: Colors.grey,
                ))));
  }

  Widget _showMobile() {
    return Padding(
        padding: EdgeInsets.only(top: 20.0),
        child: TextFormField(
            keyboardType: TextInputType.number,
            onSaved: (val) => _mobile = val,
            validator: (val) =>
                val.length < 10 ? 'Mobile number too short' : null,
            decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Mobile',
                hintText: 'Enter mobile number',
                icon: Icon(
                  Icons.mobile_screen_share,
                  color: Colors.grey,
                ))));
  }

  Widget _showPassword() {
    return Padding(
        padding: EdgeInsets.only(top: 20.0),
        child: TextFormField(
            onSaved: (val) => _password = val,
            validator: (val) =>
                val.length < 8 ? 'Mobile number too short' : null,
            obscureText: _obscureText,
            decoration: InputDecoration(
                suffixIcon: GestureDetector(
                  onTap: () {
                    setState(() => _obscureText = !_obscureText);
                  },
                  child: Icon(
                      _obscureText ? Icons.visibility : Icons.visibility_off),
                ),
                border: OutlineInputBorder(),
                labelText: 'Password',
                hintText: 'Enter password',
                icon: Icon(
                  Icons.lock,
                  color: Colors.grey,
                ))));
  }

  Widget _showSubmitButton() {
    return Padding(
        padding: EdgeInsets.only(top: 20.0),
        child: Column(
          children: <Widget>[
            _isSubmitting == true
                ? CircularProgressIndicator(
                    valueColor:
                        AlwaysStoppedAnimation(Theme.of(context).primaryColor),
                  )
                : RaisedButton(
                    child: Text(
                      'Submit',
                      style: Theme.of(context)
                          .textTheme
                          .bodyText2
                          .copyWith(color: Colors.black),
                    ),
                    elevation: 8.0,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10.0))),
                    color: Theme.of(context).primaryColor,
                    onPressed: () => _submit(),
                  ),
            FlatButton(
              child: Text('Existing user? Login'),
              onPressed: () => Navigator.pushReplacementNamed(context, '/'),
            )
          ],
        ));
  }

  void _submit() {
    final form = _formKey.currentState;

    if (form.validate()) {
      form.save();
      _registerUser();
    } else {
      print('invalid form');
    }
  }

  void _registerUser() async {
    setState(() => _isSubmitting = true);
    var body = {"name": _name, "phone": _mobile, "password": _password};
    http.Response response = await http.post(hostUrl + '/api/v0/users/auth',
        headers: {'Content-Type': 'application/json'}, body: json.encode(body));

    final responseData = json.decode(response.body);

    if (response.statusCode == 201) {
      setState(() => _isSubmitting = false);
      await _storeUserData(responseData);
      _showSuccessSnack();
      _redirectUser();
    } else {
      setState(() => _isSubmitting = false);
      final String errorMsg = responseData['message'];
      _showErrorSnack(errorMsg);
    }
  }

  Future<void> _storeUserData(responseData) async {
    final prefs = await SharedPreferences.getInstance();
    Map<String, dynamic> user = responseData['user'];
    user.putIfAbsent('jwt', () => responseData['token']);
    prefs.setString('user', json.encode(user));
    _user = User.fromJson(json.decode(prefs.getString('user')));
  }

  void _redirectUser() {
    Future.delayed(Duration(seconds: 2), () {
      Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => FirebaseFCM(user: _user)));
    });
  }

  void _showErrorSnack(String error) {
    final snackbar =
        SnackBar(content: Text(error, style: TextStyle(color: Colors.red)));

    _scaffoldKey.currentState.showSnackBar(snackbar);
  }

  void _showSuccessSnack() {
    final snackbar = SnackBar(
        content: Text('User $_mobile successfully created!',
            style: TextStyle(color: Colors.green)));

    _scaffoldKey.currentState.showSnackBar(snackbar);
    _formKey.currentState.reset();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text("Register"),
        centerTitle: true,
      ),
      body: Container(
        padding: EdgeInsets.symmetric(horizontal: 20.0),
        child: Center(
          child: SingleChildScrollView(
              child: Form(
            key: _formKey,
            child: Column(
              children: <Widget>[
                _showTitle(),
                _showName(),
                _showMobile(),
                _showPassword(),
                _showSubmitButton()
              ],
            ),
          )),
        ),
      ),
    );
  }
}
