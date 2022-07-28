import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class NoScheduleAvailable extends StatelessWidget {
  final String errorType;
  final CupertinoAlertDialog? cupertinoAlertDialog;
  const NoScheduleAvailable(
      {Key? key, required this.errorType, required this.cupertinoAlertDialog})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Container(
        padding: const EdgeInsets.all(50.0),
        child: Center(
            child: Wrap(
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Text(errorType,
                style: TextStyle(
                    color: Theme.of(context).colorScheme.onBackground,
                    fontSize: 20,
                    fontWeight: FontWeight.w500)),
            Padding(
              padding: const EdgeInsets.only(top: 3, left: 3),
              child: IconButton(
                  iconSize: 20,
                  color: Theme.of(context).colorScheme.primary,
                  onPressed: () => cupertinoAlertDialog != null
                      ? showCupertinoDialog(
                          context: context,
                          builder: (context) {
                            return cupertinoAlertDialog!;
                          })
                      : null,
                  icon: const Icon(CupertinoIcons.info_circle)),
            )
          ],
        )),
      ),
    ]);
  }
}
