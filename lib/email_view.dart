import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_ui/flutter_firebase_ui.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'l10n/localization.dart';
import 'password_view.dart';
import 'sign_up_view.dart';
import 'utils.dart';

class EmailView extends StatefulWidget {
  final bool emailWithLink;
  final bool passwordCheck;
  final EmailLinkParameter emailLinkParameter;

  EmailView(
      {Key key,
      this.emailWithLink,
      this.passwordCheck,
      this.emailLinkParameter})
      : super(key: key);

  @override
  _EmailViewState createState() => new _EmailViewState();
}

class _EmailViewState extends State<EmailView> {
  final TextEditingController _controllerEmail = new TextEditingController();

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: Text(FFULocalizations.of(context).welcome),
          elevation: 4.0,
        ),
        body: Builder(
          builder: (BuildContext context) {
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: <Widget>[
                  TextField(
                    controller: _controllerEmail,
                    autofocus: true,
                    onSubmitted: _submit,
                    keyboardType: TextInputType.emailAddress,
                    autocorrect: false,
                    decoration: new InputDecoration(
                        labelText: FFULocalizations.of(context).emailLabel),
                  ),
                ],
              ),
            );
          },
        ),
        persistentFooterButtons: <Widget>[
          ButtonBar(
            alignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              FlatButton(
                  onPressed: () => _connexion(context),
                  child: Row(
                    children: <Widget>[
                      Text(FFULocalizations.of(context).nextButtonLabel),
                    ],
                  )),
            ],
          )
        ],
        floatingActionButton: FloatingActionButton(
          onPressed: null,
          child: Icon(Icons.add),
        ),
      );

  _submit(String submitted) {
    _connexion(context);
  }

  _connexion(BuildContext context) async {

    try {
      final FirebaseAuth auth = FirebaseAuth.instance;
      List<String> providers =
          await auth.fetchSignInMethodsForEmail(email: _controllerEmail.text);

      if (providers == null || providers.isEmpty) {
        // New User
        bool connected = await Navigator.of(context).push(
          MaterialPageRoute<bool>(builder: (BuildContext context) {
            return SignUpView(_controllerEmail.text, widget.passwordCheck);
          }),
        );

        if (connected) {
          Navigator.pop(context);
        }
      } else if (providers.contains('password')) {
        if (widget.emailWithLink) {
          // Using email and link
          SharedPreferences prefs = await SharedPreferences.getInstance();
          await prefs.setString(kLoginEmail, _controllerEmail.text);
          await auth.sendSignInWithEmailLink(
            email: _controllerEmail.text,
            url: widget.emailLinkParameter.url,
            handleCodeInApp: widget.emailLinkParameter.handleCodeInApp,
            iOSBundleID: widget.emailLinkParameter.iOSBundleID,
            androidPackageName: widget.emailLinkParameter.androidPackageName,
            androidInstallIfNotAvailable:
                widget.emailLinkParameter.androidInstallIfNotAvailable,
            androidMinimumVersion:
                widget.emailLinkParameter.androidMinimumVersion,
          );
          print('link sended');
        } else {
          // Using email and password
          bool connected = await Navigator.of(context).push(
            MaterialPageRoute<bool>(builder: (BuildContext context) {
              return PasswordView(_controllerEmail.text);
            }),
          );

          if (connected) {
            Navigator.pop(context);
          }
        }
      } else {
        String provider = await _showDialogSelectOtherProvider(
            _controllerEmail.text, providers);
        if (provider.isNotEmpty) {
          Navigator.pop(context, provider);
        }
      }
    } catch (exception) {
      print(exception);
    }
  }

  _showDialogSelectOtherProvider(String email, List<String> providers) {
    var providerName = _providersToString(providers);
    return showDialog<String>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) => new AlertDialog(
        content: new SingleChildScrollView(
            child: new ListBody(
          children: <Widget>[
            new Text(FFULocalizations.of(context)
                .allReadyEmailMessage(email, providerName)),
            new SizedBox(
              height: 16.0,
            ),
            new Column(
              children: providers.map((String p) {
                return new RaisedButton(
                  child: new Row(
                    children: <Widget>[
                      new Text(_providerStringToButton(p)),
                    ],
                  ),
                  onPressed: () {
                    Navigator.of(context).pop(p);
                  },
                );
              }).toList(),
            )
          ],
        )),
        actions: <Widget>[
          new FlatButton(
            child: new Row(
              children: <Widget>[
                new Text(FFULocalizations.of(context).cancelButtonLabel),
              ],
            ),
            onPressed: () {
              Navigator.of(context).pop('');
            },
          ),
        ],
      ),
    );
  }

  String _providersToString(List<String> providers) {
    return providers.map((String provider) {
      ProvidersTypes type = stringToProvidersType(provider);
      return providersDefinitions(context)[type]?.name;
    }).join(", ");
  }

  String _providerStringToButton(String provider) {
    ProvidersTypes type = stringToProvidersType(provider);
    return providersDefinitions(context)[type]?.label;
  }
}
