import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'l10n/localization.dart';
import 'utils.dart';

class SignUpView extends StatefulWidget {
  final String email;
  final bool passwordCheck;

  SignUpView({Key key, this.email, this.passwordCheck}) : super(key: key);

  @override
  _SignUpViewState createState() => new _SignUpViewState();
}

class _SignUpViewState extends State<SignUpView> {
  TextEditingController _controllerEmail;
  TextEditingController _controllerDisplayName;
  TextEditingController _controllerPassword;
  TextEditingController _controllerCheckPassword;

  final FocusNode _focusPassword = FocusNode();

  bool _valid = false;

  @override
  dispose() {
    _focusPassword.dispose();
    super.dispose();
  }

  @override
  initState() {
    super.initState();
    _controllerEmail = new TextEditingController(text: widget.email);
    _controllerDisplayName = new TextEditingController();
    _controllerPassword = new TextEditingController();
    _controllerCheckPassword = new TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    _controllerEmail.text = widget.email;
    return new Scaffold(
      appBar: new AppBar(
        title: new Text(FFULocalizations.of(context).signUpTitle),
        elevation: 4.0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: <Widget>[
            TextField(
              controller: _controllerEmail,
              keyboardType: TextInputType.emailAddress,
              autocorrect: false,
              onSubmitted: _submit,
              decoration: InputDecoration(labelText: FFULocalizations.of(context).emailLabel),
            ),
            const SizedBox(height: 8.0),
            TextField(
              controller: _controllerDisplayName,
              autofocus: true,
              keyboardType: TextInputType.text,
              autocorrect: false,
              onChanged: _checkValid,
              onSubmitted: _submitDisplayName,
              decoration: InputDecoration(labelText: FFULocalizations.of(context).nameLabel),
            ),
            const SizedBox(height: 8.0),
            TextField(
              controller: _controllerPassword,
              obscureText: true,
              autocorrect: false,
              onSubmitted: _submit,
              focusNode: _focusPassword,
              decoration: new InputDecoration(labelText: FFULocalizations.of(context).passwordLabel),
            ),
            !widget.passwordCheck
                ? Container()
                : TextField(
                    controller: _controllerCheckPassword,
                    obscureText: true,
                    autocorrect: false,
                    decoration: new InputDecoration(labelText: FFULocalizations.of(context).passwordCheckLabel),
                  ),
          ],
        ),
      ),
      persistentFooterButtons: <Widget>[
        new ButtonBar(
          alignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            new FlatButton(
                onPressed: _valid ? () => _connexion(context) : null,
                child: new Row(
                  children: <Widget>[
                    new Text(FFULocalizations.of(context).saveLabel),
                  ],
                )),
          ],
        )
      ],
    );
  }

  _submitDisplayName(String submitted) {
    FocusScope.of(context).requestFocus(_focusPassword);
  }

  _submit(String submitted) {
    _connexion(context);
  }

  _connexion(BuildContext context) async {
    if (widget.passwordCheck && _controllerPassword.text != _controllerCheckPassword.text) {
      showErrorDialog(context, FFULocalizations.of(context).passwordCheckError);
      return;
    }

    FirebaseAuth _auth = FirebaseAuth.instance;
    try {
      AuthResult authResult = await _auth.createUserWithEmailAndPassword(
        email: _controllerEmail.text,
        password: _controllerPassword.text,
      );
      FirebaseUser user = authResult.user;
      try {
        var userUpdateInfo = new UserUpdateInfo();
        userUpdateInfo.displayName = _controllerDisplayName.text;
        await user.updateProfile(userUpdateInfo);
        Navigator.pop(context, true);
      } catch (e) {
        showErrorDialog(context, e.details);
      }
    } on PlatformException catch (ex) {
      processPlatformException(context, ex);
    } catch (e) {
      showErrorDialog(context, e.message);
    }
  }

  void _checkValid(String value) {
    setState(() {
      _valid = _controllerDisplayName.text.isNotEmpty;
    });
  }
}
