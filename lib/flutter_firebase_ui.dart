library firebase_ui;

import 'package:flutter/material.dart';

import 'email_link_parameter.dart';
import 'login_view.dart';
import 'utils.dart';

export 'email_link_parameter.dart';
export 'utils.dart';

class SignInScreen extends StatefulWidget {
  SignInScreen(
      {Key key,
      this.title,
      this.header,
      this.footer,
      this.emailWithLink = false,
      this.emailLinkParameter,
      this.signUpPasswordCheck,
      this.providers,
      this.color = Colors.white,
      @required this.showBar,
      @required this.avoidBottomInset,
      @required this.bottomPadding,
      @required this.horizontalPadding})
      : assert(!emailWithLink || (emailWithLink && emailLinkParameter != null)),
        super(key: key);

  final String title;
  final Widget header;
  final Widget footer;
  final List<ProvidersTypes> providers;
  final Color color;
  final bool emailWithLink;
  final EmailLinkParameter emailLinkParameter;
  final bool signUpPasswordCheck;
  final bool showBar;
  final bool avoidBottomInset;
  final double horizontalPadding;
  final double bottomPadding;

  @override
  _SignInScreenState createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  Widget get _header => widget.header ?? Container();
  Widget get _footer => widget.footer ?? Container();

  bool get _passwordCheck => widget.signUpPasswordCheck ?? false;
  bool get _emailWithLink => widget.emailWithLink ?? false;
  EmailLinkParameter get _emailLinkParameter => widget.emailLinkParameter ?? null;

  List<ProvidersTypes> get _providers => widget.providers ?? [ProvidersTypes.email];

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: widget.showBar
            ? AppBar(
                title: Text(widget.title),
                elevation: 4.0,
              )
            : null,
        resizeToAvoidBottomInset: widget.avoidBottomInset,
        body: Builder(
          builder: (BuildContext context) {
            return Container(
              decoration: BoxDecoration(color: widget.color),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  _header,
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: widget.horizontalPadding),
                      child: LoginView(
                        providers: _providers,
                        emailWithLink: _emailWithLink,
                        emailLinkParameter: _emailLinkParameter,
                        passwordCheck: _passwordCheck,
                        bottomPadding: widget.bottomPadding,
                      ),
                    ),
                  ),
                  _footer
                ],
              ),
            );
          },
        ),
      );
}
