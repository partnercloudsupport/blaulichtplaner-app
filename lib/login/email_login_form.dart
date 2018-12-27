import 'package:flutter/material.dart';

typedef void EmailLoginHandler(String email, String password);

class EmailLoginForm extends StatefulWidget {
  final EmailLoginHandler emailLogin;

  const EmailLoginForm({Key key, @required this.emailLogin}) : super(key: key);
  @override
  State<StatefulWidget> createState() => EmailLoginFormState();
}

class EmailLoginFormState extends State<EmailLoginForm> {
  String _password;
  String _email;
  TextEditingController _passwordController;
  TextEditingController _emailController;
  GlobalKey<FormState> _formKey = GlobalKey<FormState>();
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
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          TextFormField(
            decoration: InputDecoration(helperText: 'E-Mail'),
            controller: _emailController,
            validator: (String value) {
              if (value.isEmpty) {
                return 'Bitte E-Mail-Adresse eingeben!';
              }
            },
          ),
          TextFormField(
            decoration: InputDecoration(helperText: 'Passwort'),
            controller: _passwordController,
            validator: (String value){
              if(value.isEmpty){
                return 'Bitte Passwort eingeben!';
              }
            },
          ),
          RaisedButton(
            color: Colors.blue,
            onPressed: () {
              if (_formKey.currentState.validate()) {
                widget.emailLogin(_email, _password);
              }
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
