import 'package:basketballdata/basketballdata.dart';
import 'package:flutter/material.dart';

import '../../messages.dart';

typedef PeriodCallback = void Function(GamePeriod period);

class PeriodDropdown extends StatelessWidget {
  final PeriodCallback onPeriodChange;
  final GamePeriod value;

  PeriodDropdown({this.onPeriodChange, this.value});

  @override
  Widget build(BuildContext context) {
    return DropdownButton<GamePeriod>(
      icon: Icon(Icons.arrow_downward),
      iconSize: 24,
      elevation: 16,
      onChanged: onPeriodChange,
      value: value,
      items: GamePeriod.values
          .map(
            (GamePeriod p) => DropdownMenuItem(
              child: Text(
                Messages.of(context).getPeriodName(p),
                textScaleFactor: 1.5,
              ),
              value: p,
            ),
          )
          .toList(),
    );
  }
}
