import 'package:email_validator/email_validator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show PlatformException;

import 'email_link_parameter.dart';
import 'l10n/localization.dart';
import 'link_sent_view.dart';
import 'password_view.dart';
import 'sign_up_view.dart';
import 'utils.dart';

class EmailView extends StatefulWidget {
  final bool emailWithLink;
  final bool passwordCheck;
  final EmailLinkParameter emailLinkParameter;

  EmailView({Key key, this.emailWithLink, this.passwordCheck, this.emailLinkParameter}) : super(key: key);

  @override
  _EmailViewState createState() => new _EmailViewState();
}

class _EmailViewState extends State<EmailView> {
  final TextEditingController _controllerEmail = TextEditingController();
  String _errorMessage;
  bool _loading = false;

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
                    onChanged: (_) => setState(() {
                      _errorMessage = null;
                    }),
                    onSubmitted: _submit,
                    keyboardType: TextInputType.emailAddress,
                    autocorrect: false,
                    decoration: new InputDecoration(
                      labelText: FFULocalizations.of(context).emailLabel,
                      errorText: _errorMessage,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
        persistentFooterButtons: <Widget>[
          _loading
              ? CircularProgressIndicator()
              : FlatButton(
                  onPressed: () => _connexion(context),
                  child: Text(FFULocalizations.of(context).nextButtonLabel),
                ),
        ],
      );

  _submit(String submitted) {
    _connexion(context);
  }

  _connexion(BuildContext context) async {
    if (_loading) return;

    if (!EmailValidator.validate(_controllerEmail.text)) {
      setState(() {
        _errorMessage = FFULocalizations.of(context).emailCheckError;
      });
      return;
    }
    setState(() {
      _loading = true;
    });
    try {
      final FirebaseAuth auth = FirebaseAuth.instance;
      List<String> providers = await auth.fetchSignInMethodsForEmail(email: _controllerEmail.text);

      if (providers == null || providers.isEmpty || providers.contains('password') || providers.contains("emailLink")) {
        // use email/link to sign up or sign in
        if (widget.emailWithLink || (providers != null && providers.contains("emailLink")) ) {
          // Using email and link
          await sendSingInLink(context, _controllerEmail.text, widget.emailLinkParameter);
          await Navigator.of(context).push(
            MaterialPageRoute(builder: (BuildContext context) {
              return LinkSentView(
                email: _controllerEmail.text,
                emailLinkParameter: widget.emailLinkParameter,
              );
            }),
          );
        } else if (providers == null || providers.isEmpty) {
          // New User
          bool connected = await Navigator.of(context).push(
            MaterialPageRoute<bool>(builder: (BuildContext context) {
              return SignUpView(email: _controllerEmail.text, passwordCheck: widget.passwordCheck);
            }),
          );

          if (connected) {
            Navigator.pop(context);
          }
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
        String provider = await _showDialogSelectOtherProvider(_controllerEmail.text, providers);
        if (provider.isNotEmpty) {
          Navigator.pop(context, provider);
        }
      }
    } on PlatformException catch (ex) {
      processPlatformException(context, ex);
    } catch (e) {
      showErrorDialog(context, "Message: $e", title: "Unknown error");
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  _showDialogSelectOtherProvider(String email, List<String> providers) {
    var providerName = _providersToString(providers);
    return showDialog<String>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) => AlertDialog(
        content: SingleChildScrollView(
          child: ListBody(
            children: <Widget>[
              Text(FFULocalizations.of(context).allReadyEmailMessage(email, providerName)),
              SizedBox(
                height: 16.0,
              ),
              Column(
                children: providers.map((String p) {
                  return RaisedButton(
                    child: Text(_providerStringToButton(p)),
                    onPressed: () {
                      Navigator.of(context).pop(p);
                    },
                  );
                }).toList(),
              ),
            ],
          ),
        ),
        actions: <Widget>[
          FlatButton(
            child: Text(FFULocalizations.of(context).cancelButtonLabel),
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
