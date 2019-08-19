import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';

import 'l10n/localization.dart';

class EmailConfirmationDialog extends StatefulWidget {
  @override
  _EmailConfirmationDialogState createState() => _EmailConfirmationDialogState();
}

class _EmailConfirmationDialogState extends State<EmailConfirmationDialog> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  String _email;
  bool _autoValidate = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      child: AlertDialog(
        title: Text(FFULocalizations.of(context).emailConfirmTitle),
        content: SingleChildScrollView(
          child: Form(
            key: _formKey,
            autovalidate: _autoValidate,
            child: ListBody(
              children: <Widget>[
                Text(
                  FFULocalizations.of(context).emailConfirmMessage,
                ),
                Padding(
                  padding: EdgeInsets.all(10.0),
                ),
                TextFormField(
                  validator: (String value) {
                    return EmailValidator.validate(value) ? null : FFULocalizations.of(context).emailCheckError;
                  },
                  onSaved: (String val) {
                    _email = val;
                  },
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  autofocus: true,
                  decoration: InputDecoration(
                    labelText: FFULocalizations.of(context).emailLabel,
                  ),
                ),
              ],
            ),
          ),
        ),
        actions: <Widget>[
          FlatButton(
            child: Text(FFULocalizations.of(context).cancelButtonLabel),
            onPressed: () {
              Navigator.of(context, rootNavigator: true).pop('');
            },
          ),
          FlatButton(
            child: Text(FFULocalizations.of(context).nextButtonLabel),
            onPressed: () {
              if (_formKey.currentState.validate()) {
                _formKey.currentState.save();
              } else {
                setState(() {
                  _autoValidate = true;
                });
                return;
              }
              Navigator.of(context, rootNavigator: true).pop(_email);
            },
          ),
        ],
      ),
    );
  }
}
