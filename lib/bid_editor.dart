import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class BidEditor extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return new BidEditorState();
  }
}

class BidEditorState extends State<BidEditor> {
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text("Dienstbewerbung")),
        body: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: TextFormField(
                              enabled: false,
                              decoration:
                                  const InputDecoration(labelText: "von", counterText:"1/12"),
                              validator: (value) =>
                                  value.isEmpty ? "Feld erforderlich" : null,
                            ),
                          ),
                        ),
                        Expanded(
                          child: TextFormField(
                            decoration:
                                const InputDecoration(hintText: "bis"),
                            validator: (value) =>
                                value.isEmpty ? "Feld erforderlich" : null,
                          ),
                        )
                      ],
                    ),
                    Row(
                      children: <Widget>[
                        Expanded(
                          child: DropdownButton(items: [
                            DropdownMenuItem(child: Text("min. 12 Stunden")),
                            DropdownMenuItem(child: Text("min. 24 Stunden")),
                            DropdownMenuItem(child: Text("min. 48 Stunden"))
                          ], onChanged: null),
                        ),
                        Expanded(
                          child: DropdownButton(items: [
                            DropdownMenuItem(child: Text("max. 12 Stunden")),
                            DropdownMenuItem(child: Text("max. 24 Stunden")),
                            DropdownMenuItem(child: Text("max. 48 Stunden"))
                          ], onChanged: null),
                        ),
                      ],
                    ),
                    TextField(
                      maxLines: 3,
                      decoration: InputDecoration(helperText: "Bemerkungen"),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                      child: RaisedButton(
                        onPressed: () {
                          // Validate will return true if the form is valid, or false if
                          // the form is invalid.
                          if (_formKey.currentState.validate()) {
                            // If the form is valid, we want to show a Snackbar
                            Scaffold.of(context).showSnackBar(
                                SnackBar(content: Text('Processing Data')));
                          }
                        },
                        child: Text('Speichern'),
                      ),
                    ),
                  ]),
            ),
          ),
        ));
  }
}
