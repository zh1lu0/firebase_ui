import 'package:flutter/material.dart';

import 'email_link_parameter.dart';
import 'l10n/localization.dart';
import 'utils.dart';

class LinkSentView extends StatelessWidget {
  final String email;
  final EmailLinkParameter emailLinkParameter;

  const LinkSentView({Key key, @required this.email, @required this.emailLinkParameter}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(FFULocalizations.of(context).emailSentTitle),
        ),
        body: Container(
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    FFULocalizations.of(context).emailSentMessage(email),
                    style: TextStyle(fontSize: 18.0),
                  ),
                  SizedBox(
                    height: 16.0,
                  ),
                  InkWell(
                    child: Text(
                      FFULocalizations.of(context).troubleGettingEmailLabel,
                      style: TextStyle(
                        color: Colors.blue,
                        fontSize: 14.0,
                      ),
                    ),
                    onTap: () {
                      showDialog<bool>(
                        context: context,
                        builder: (BuildContext context) => AlertDialog(
                          title: Text(FFULocalizations.of(context).troubleGettingEmailLabel),
                          content: Text(FFULocalizations.of(context).troubleGettingEmailMessage),
                          actions: <Widget>[
                            FlatButton(
                              child: Text(FFULocalizations.of(context).resendButtonLabel),
                              onPressed: () => Navigator.pop(context, true),
                            ),
                            FlatButton(
                              child: Text(FFULocalizations.of(context).cancelButtonLabel),
                              onPressed: () => Navigator.pop(context, false),
                            ),
                          ],
                        ),
                      ).then((resend) {
                        if (resend) {
                          sendSingInLink(context, email, emailLinkParameter);
                        }
                      });
                    },
                  )
                ],
              ),
            ),
          ),
        ));
  }
}
