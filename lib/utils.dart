import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_ui/l10n/localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_facebook_login/flutter_facebook_login.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'email_link_parameter.dart';
import 'progress_dialog.dart';

enum ProvidersTypes { email, google, facebook, phone }

final String kLoginEmail = 'kLoginEmail';
final GoogleSignIn googleSignIn = new GoogleSignIn();
final FacebookLogin facebookLogin = new FacebookLogin();

ProvidersTypes stringToProvidersType(String value) {
  if (value.toLowerCase().contains('facebook')) return ProvidersTypes.facebook;
  if (value.toLowerCase().contains('google')) return ProvidersTypes.google;
  if (value.toLowerCase().contains('password')) return ProvidersTypes.email;
//TODO  if (value.toLowerCase().contains('phone')) return ProvidersTypes.phone;
  return null;
}

// Description button
class ButtonDescription extends StatelessWidget {
  final String label;
  final Color labelColor;
  final Color color;
  final String logo;
  final String name;
  final VoidCallback onSelected;

  const ButtonDescription(
      {@required this.logo,
      @required this.label,
      @required this.name,
      this.onSelected,
      this.labelColor = Colors.grey,
      this.color = Colors.white});

  ButtonDescription copyWith({
    String label,
    Color labelColor,
    Color color,
    String logo,
    String name,
    VoidCallback onSelected,
  }) {
    return new ButtonDescription(
        label: label ?? this.label,
        labelColor: labelColor ?? this.labelColor,
        color: color ?? this.color,
        logo: logo ?? this.logo,
        name: name ?? this.name,
        onSelected: onSelected ?? this.onSelected);
  }

  @override
  Widget build(BuildContext context) {
    VoidCallback _onSelected = onSelected ?? () => {};
    return RaisedButton(
        color: color,
        child: Row(
          children: <Widget>[
            Container(
                padding: const EdgeInsets.fromLTRB(16.0, 16.0, 32.0, 16.0),
                child: Image.asset('assets/$logo', package: 'firebase_ui')),
            Expanded(
              child: Text(
                label,
                style: TextStyle(color: labelColor),
              ),
            )
          ],
        ),
        onPressed: _onSelected);
  }
}

Map<ProvidersTypes, ButtonDescription> providersDefinitions(BuildContext context) => {
      ProvidersTypes.facebook: new ButtonDescription(
          color: const Color.fromRGBO(59, 87, 157, 1.0),
          logo: "fb-logo.png",
          label: FFULocalizations.of(context).signInFacebook,
          name: "Facebook",
          labelColor: Colors.white),
      ProvidersTypes.google: new ButtonDescription(
          color: Colors.white,
          logo: "go-logo.png",
          label: FFULocalizations.of(context).signInGoogle,
          name: "Google",
          labelColor: Colors.grey),
      ProvidersTypes.email: new ButtonDescription(
          color: const Color.fromRGBO(219, 68, 55, 1.0),
          logo: "email-logo.png",
          label: FFULocalizations.of(context).signInEmail,
          name: "Email",
          labelColor: Colors.white),
    };

void processPlatformException(BuildContext context, PlatformException ex) {
  switch (ex.code) {
    case 'ERROR_INVALID_CREDENTIAL':
      String msg = FFULocalizations.of(context).errorInvalidCredential;
      showErrorDialog(context, msg);
      break;
    case 'ERROR_USER_DISABLED':
      String msg = FFULocalizations.of(context).errorUserDisabled;
      showErrorDialog(context, msg);
      break;
    case 'ERROR_ACCOUNT_EXISTS_WITH_DIFFERENT_CREDENTIAL':
//      String msg = FFULocalizations.of(context).errorAccountExisted;
      String msg = ex.message;
      showErrorDialog(context, msg);
      break;
    case 'ERROR_INVALID_ACTION_CODE':
      String msg = ex.message;
      showErrorDialog(context, msg);
      break;
    default:
      print(ex.code);
      showErrorDialog(context, ex.message);
  }
}

Future<void> sendSingInLink(BuildContext context, String email, EmailLinkParameter emailLinkParameter) async {
  final FirebaseAuth auth = FirebaseAuth.instance;
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.setString(kLoginEmail, email);
  await auth.sendSignInWithEmailLink(
    email: email,
    url: emailLinkParameter.url,
    handleCodeInApp: emailLinkParameter.handleCodeInApp,
    iOSBundleID: emailLinkParameter.iOSBundleID,
    androidPackageName: emailLinkParameter.androidPackageName,
    androidInstallIfNotAvailable: emailLinkParameter.androidInstallIfNotAvailable,
    androidMinimumVersion: emailLinkParameter.androidMinimumVersion,
  );
}

void showSigningDialog(BuildContext context) {
  showDialog<dynamic>(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return ProgressDialog(
        message: FFULocalizations.of(context).emailLinkChecking,
      );
    },
  );
}

Future<Null> showErrorDialog(BuildContext context, String message, {String title}) {
  return showDialog<Null>(
    context: context,
    barrierDismissible: false, // user must tap button!
    builder: (BuildContext context) => AlertDialog(
      title: title != null ? Text(title) : null,
      content: SingleChildScrollView(
        child: ListBody(
          children: <Widget>[
            Text(message ?? FFULocalizations.of(context).errorOccurred),
          ],
        ),
      ),
      actions: <Widget>[
        FlatButton(
          child: Text(FFULocalizations.of(context).cancelButtonLabel),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ],
    ),
  );
}

Future<void> signOutProviders() async {
  var currentUser = await FirebaseAuth.instance.currentUser();
  if (currentUser != null) {
    await signOut(currentUser.providerData);
  }

  return await FirebaseAuth.instance.signOut();
}

Future<dynamic> signOut(Iterable providers) async {
  return Future.forEach(providers, (p) async {
    switch (p.providerId) {
      case 'facebook.com':
        await facebookLogin.logOut();
        break;
      case 'google.com':
        await googleSignIn.signOut();
        break;
    }
  });
}
