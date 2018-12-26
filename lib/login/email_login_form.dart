import 'package:flutter/material.dart';

typedef void EmailLogin(String email, String password);

class EmailLoginForm extends StatefulWidget {
  final EmailLogin emailLogin;

  const EmailLoginForm({Key key, this.emailLogin}) : super(key: key);
  @override
  State<StatefulWidget> createState() => EmailLoginFormState();
}

class EmailLoginFormState extends State<EmailLoginForm> {
  String _password;
  String _email;
  TextEditingController _passwordController;
  TextEditingController _emailController;

  _passwordListener() {
    setState(() {
      _password = _passwordController.text;
    });
  }

  _emailListener() {
    setState(() {
      _email = _emailController.text;
    });
  }

  void initState() {
    super.initState();
    _passwordController = TextEditingController()
      ..addListener(_passwordListener);
    _emailController = TextEditingController()..addListener(_emailListener);
  }

  @override
  void dispose() {
    super.dispose();
    _emailController
      ..removeListener(_emailListener)
      ..dispose();
    _passwordController
      ..removeListener(_passwordListener)
      ..dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          TextFormField(
            decoration: InputDecoration(hintText: 'E-Mail'),
            controller: _emailController,
          ),
          TextFormField(
            decoration: InputDecoration(hintText: 'Passwort'),
            controller: _passwordController,
          ),
          RaisedButton(
            color: Colors.blue,
            onPressed: () {
              widget.emailLogin(_email, _password);
            },
            child: Text(
              'Anmelden',
              style: TextStyle(color: Colors.white),
            ),
          )
        ],
      ),
    );
  }
}
