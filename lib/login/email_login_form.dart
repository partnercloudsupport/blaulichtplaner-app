import 'package:flutter/material.dart';

typedef void EmailLoginHandler(String email, String password);

class EmailLoginForm extends StatefulWidget {
  final EmailLoginHandler emailLogin;

  const EmailLoginForm({Key key, @required this.emailLogin}) : super(key: key);
  @override
  State<StatefulWidget> createState() => EmailLoginFormState();
}

class EmailLoginFormState extends State<EmailLoginForm> {
  TextEditingController _passwordController;
  TextEditingController _emailController;
  GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          TextFormField(
            decoration: InputDecoration(helperText: 'E-Mail'),
            keyboardType: TextInputType.emailAddress,
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
            validator: (String value) {
              if (value.isEmpty) {
                return 'Bitte Passwort eingeben!';
              }
            },
            obscureText: true,
          ),
          RaisedButton(
            color: Colors.blue,
            onPressed: () {
              if (_formKey.currentState.validate()) {
                widget.emailLogin(_emailController.text, _passwordController.text);
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
