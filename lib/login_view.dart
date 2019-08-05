import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_facebook_login/flutter_facebook_login.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'email_view.dart';
import 'utils.dart';

class LoginView extends StatefulWidget {
  final List<ProvidersTypes> providers;
  final bool passwordCheck;
  final double bottomPadding;

  LoginView({Key key, @required this.providers, this.passwordCheck, @required this.bottomPadding}) : super(key: key);

  @override
  _LoginViewState createState() => new _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Map<ProvidersTypes, ButtonDescription> _buttons;

  _handleEmailSignIn() async {
    String value = await Navigator.of(context).push(new MaterialPageRoute<String>(builder: (BuildContext context) {
      return new EmailView(widget.passwordCheck);
    }));

    if (value != null) {
      _followProvider(value);
    }
  }

  _handleGoogleSignIn() async {
    GoogleSignInAccount googleUser = await googleSignIn.signIn();
    if (googleUser != null) {
      GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      if (googleAuth.accessToken != null) {
        try {
          AuthCredential credential =
              GoogleAuthProvider.getCredential(idToken: googleAuth.idToken, accessToken: googleAuth.accessToken);
          AuthResult result = await _auth.signInWithCredential(credential);
          print(result.user);
        } catch (e) {
          showErrorDialog(context, e.details);
        }
      }
    }
  }

  _handleFacebookSignIn() async {
    FacebookLoginResult facebookResult = await facebookLogin.logInWithReadPermissions(['email']);
    if (facebookResult.accessToken != null) {
      try {
        AuthCredential credential = FacebookAuthProvider.getCredential(accessToken: facebookResult.accessToken.token);
        AuthResult result = await _auth.signInWithCredential(credential);
        print(result.user);
      } catch (e) {
        showErrorDialog(context, e.details);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    _buttons = {
      ProvidersTypes.facebook:
          providersDefinitions(context)[ProvidersTypes.facebook].copyWith(onSelected: _handleFacebookSignIn),
      ProvidersTypes.google:
          providersDefinitions(context)[ProvidersTypes.google].copyWith(onSelected: _handleGoogleSignIn),
      ProvidersTypes.email:
          providersDefinitions(context)[ProvidersTypes.email].copyWith(onSelected: _handleEmailSignIn),
    };

    return new Container(
        // padding: widget.padding,
        child: new Column(
            children: widget.providers.map((p) {
      return new Container(
          padding: EdgeInsets.only(bottom: widget.bottomPadding), child: _buttons[p] ?? new Container());
    }).toList()));
  }

  void _followProvider(String value) {
    ProvidersTypes provider = stringToProvidersType(value);
    if (provider == ProvidersTypes.facebook) {
      _handleFacebookSignIn();
    } else if (provider == ProvidersTypes.google) {
      _handleGoogleSignIn();
    }
  }
}
