import 'package:flutter/foundation.dart';

class EmailLinkParameter {
  final String url;
  final bool handleCodeInApp;
  final String iOSBundleID;
  final String androidPackageName;
  final bool androidInstallIfNotAvailable;
  final String androidMinimumVersion;

  EmailLinkParameter(
      {@required this.url,
      @required this.handleCodeInApp,
      @required this.iOSBundleID,
      @required this.androidPackageName,
      @required this.androidInstallIfNotAvailable,
      @required this.androidMinimumVersion});
}
