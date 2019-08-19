import 'package:flutter/material.dart';

class ProgressDialog extends StatelessWidget {
  final String message;

  const ProgressDialog({Key key, this.message = "Loading..."}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Dialog(
        insetAnimationCurve: Curves.easeInOut,
        insetAnimationDuration: Duration(milliseconds: 100),
        elevation: 10.0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(10.0))),
        child: SizedBox(
          height: 100.0,
          child: Row(
            children: <Widget>[
              const SizedBox(width: 15.0),
              SizedBox(
                width: 60.0,
                child: Image(
                  image: AssetImage('assets/double_ring_loading_io.gif', package: 'firebase_ui'),
                ),
              ),
              const SizedBox(width: 15.0),
              Expanded(
                child:
                    Text(message, textAlign: TextAlign.justify, style: TextStyle(color: Colors.black, fontSize: 18.0)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
