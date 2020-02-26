import 'package:flutter/material.dart';

///
/// Shows the point adding items as buttons on the screen.
///
class PointsWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Row(
          children: <Widget>[
            FlatButton(
              onPressed: () {},
              child: Text("3"),
              shape: new CircleBorder(),
              color: Colors.blue,
            ),
            FlatButton(
              onPressed: () {},
              child: Text(
                "3",
                style: Theme.of(context)
                    .textTheme
                    .button
                    .copyWith(decoration: TextDecoration.lineThrough),
              ),
              shape: new CircleBorder(),
              color: Colors.red,
            )
          ],
        ),
        Row(
          children: <Widget>[
            FlatButton(
              onPressed: () {},
              child: Text("2",
                  style: Theme.of(context)
                      .textTheme
                      .button
                      .copyWith(color: Colors.white)),
              shape: new CircleBorder(),
              color: Colors.blue,
            ),
            FlatButton(
              onPressed: () {},
              child: Text(
                "2",
                style: Theme.of(context).textTheme.button.copyWith(
                    decoration: TextDecoration.lineThrough,
                    color: Colors.white),
              ),
              shape: new CircleBorder(),
              color: Colors.red,
            )
          ],
        )
      ],
    );
  }
}
