import 'package:flutter/material.dart';

class ResetPasswordForm extends StatefulWidget {
  final Function(String email) onReset;
  final bool loading;

  ResetPasswordForm({Key key, @required this.loading, @required this.onReset})
      : super(key: key);

  @override
  _ResetPasswordFormState createState() => _ResetPasswordFormState();
}

class _ResetPasswordFormState extends State<ResetPasswordForm> {
  final TextEditingController _emailController = TextEditingController();
  final GlobalKey<FormState> _resetFormKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _resetFormKey,
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
          Visibility(
            visible: !widget.loading,
            child: Padding(
              padding: EdgeInsets.only(top: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  RaisedButton(
                    color: Colors.blue,
                    onPressed: () {
                      if (_resetFormKey.currentState.validate()) {
                        widget.onReset(_emailController.text);
                      }
                    },
                    child: Text(
                      'Passwort zurücksetzen',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Visibility(
              visible: widget.loading,
              child: Center(child: CircularProgressIndicator()))
        ],
      ),
    );
  }
}
