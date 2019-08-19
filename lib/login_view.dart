import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:firebase_ui/flutter_firebase_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_facebook_login/flutter_facebook_login.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'email_confirmation_dialog.dart';
import 'email_link_parameter.dart';
import 'email_view.dart';
import 'utils.dart';

class LoginView extends StatefulWidget {
  final List<ProvidersTypes> providers;
  final bool emailWithLink;
  final EmailLinkParameter emailLinkParameter;
  final bool passwordCheck;
  final double bottomPadding;

  LoginView(
      {Key key,
      @required this.providers,
      this.emailWithLink,
      this.emailLinkParameter,
      this.passwordCheck,
      @required this.bottomPadding})
      : super(key: key);

  @override
  _LoginViewState createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  bool _busy = false;

  Map<ProvidersTypes, ButtonDescription> _buttons;

  @override
  void initState() {
    super.initState();
    this._initDynamicLinks();
  }

  _setBusy(bool busy) {
    setState(() {
      _busy = busy;
    });
  }

  void _initDynamicLinks() async {
    final PendingDynamicLinkData data = await FirebaseDynamicLinks.instance.getInitialLink();
    final Uri deepLink = data?.link;
    if (deepLink != null) {
      if (await _auth.isSignInWithEmailLink(deepLink.toString())) {
        await _handleLinkSignIn(deepLink.toString());
      }
    }

    FirebaseDynamicLinks.instance.onLink(onSuccess: (PendingDynamicLinkData dynamicLink) async {
      final Uri deepLink = dynamicLink?.link;
      if (deepLink != null) {
        if (await _auth.isSignInWithEmailLink(deepLink.toString())) {
          await _handleLinkSignIn(deepLink.toString());
        }
      }
    }, onError: (OnLinkErrorException e) async {
      print(e.message);
    });
  }

  Future<String> _showEmailConfirmationDialog() {
    return showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) => EmailConfirmationDialog(),
    );
  }

  _handleLinkSignIn(String link) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String email = prefs.getString(kLoginEmail) ?? "";
    if (email == "") {
      String promptEmail = await _showEmailConfirmationDialog();
      if (promptEmail != '') {
        email = promptEmail;
      } else {
        return false;
      }
    }
    try {
      showSigningDialog(context);
      await Future.delayed(Duration(milliseconds: 50));
      await _auth.signInWithEmailAndLink(email: email, link: link);
      prefs.remove(kLoginEmail);
      Navigator.of(context, rootNavigator: true).pop();
      Navigator.popUntil(context, (Route<dynamic> route) => route.isFirst);
    } on PlatformException catch (ex) {
      Navigator.of(context, rootNavigator: true).pop();
      processPlatformException(context, ex);
    } catch (e) {
      Navigator.of(context, rootNavigator: true).pop();
      showErrorDialog(context, e.message);
    }
  }

  _handleEmailSignIn() async {
    String value = await Navigator.of(context).push(
      MaterialPageRoute<String>(builder: (BuildContext context) {
        return EmailView(
          emailWithLink: widget.emailWithLink,
          emailLinkParameter: widget.emailLinkParameter,
          passwordCheck: widget.passwordCheck,
        );
      }),
    );

    if (value != null) {
      _followProvider(value);
    }
  }

  _handleGoogleSignIn() async {
    _setBusy(true);
    try {
      GoogleSignInAccount googleUser = await googleSignIn.signIn();
      if (googleUser != null) {
        GoogleSignInAuthentication googleAuth = await googleUser.authentication;
        if (googleAuth.accessToken != null) {
          AuthCredential credential =
              GoogleAuthProvider.getCredential(idToken: googleAuth.idToken, accessToken: googleAuth.accessToken);
          await _auth.signInWithCredential(credential);
        } else {
          _setBusy(false);
        }
      } else {
        _setBusy(false);
      }
    } on PlatformException catch (ex) {
      _setBusy(false);
      processPlatformException(context, ex);
    } catch (e) {
      _setBusy(false);
      showErrorDialog(context, e.details);
    }
  }

  _handleFacebookSignIn() async {
    _setBusy(true);
    try {
      FacebookLoginResult facebookResult = await facebookLogin.logInWithReadPermissions(['email']);
      if (facebookResult.accessToken != null) {
        AuthCredential credential = FacebookAuthProvider.getCredential(accessToken: facebookResult.accessToken.token);
        await _auth.signInWithCredential(credential);
      } else {
        _setBusy(false);
      }
    } on PlatformException catch (ex) {
      _setBusy(false);
      processPlatformException(context, ex);
    } catch (e) {
      _setBusy(false);
      showErrorDialog(context, e.message);
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

    return Container(
      // padding: widget.padding,
      child: Stack(
        children: <Widget>[
          Column(
            children: widget.providers.map((p) {
              return Container(
                padding: EdgeInsets.only(bottom: widget.bottomPadding),
                child: _buttons[p] ?? Container(),
              );
            }).toList(),
          ),
          _busy
              ? Opacity(
                  child: ModalBarrier(
                    dismissible: false,
                    color: Colors.white,
                  ),
                  opacity: 0.5,
                )
              : Container(),
          _busy ? CircularProgressIndicator() : Container(),
        ],
        alignment: Alignment.center,
      ),
    );
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
