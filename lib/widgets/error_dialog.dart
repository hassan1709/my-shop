import 'package:flutter/material.dart';

class ErrorDialog {
  static Future<void> showErrorDialog(
    BuildContext context,
    String content,
  ) {
    return showDialog<Null>(
        context: context,
        builder: (ctx) => AlertDialog(
              title: Text('An error has occurred'),
              content: Text(content),
              actions: <Widget>[
                TextButton(
                  child: Text('Okay!'),
                  onPressed: () {
                    Navigator.of(ctx).pop();
                  },
                ),
              ],
            ));
  }
}
