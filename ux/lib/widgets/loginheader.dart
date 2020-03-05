import 'package:flutter/material.dart';

///
/// The header to display in all the login screens.
///
class LoginHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;

    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Center(
            child: Image(
              image: ExactAssetImage("assets/images/abstractsport.png"),
              width: (screenSize.width < 500)
                  ? 120.0
                  : (screenSize.width / 4) + 12.0,
              height: screenSize.height / 4 + 20,
            ),
          ),
        ],
      ),
    );
  }
}
