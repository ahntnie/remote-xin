import 'package:flutter/material.dart';

import '../../../../../models/all.dart';
import '../../../../resource/styles/styles.dart';

// ignore: must_be_immutable
class ExpansionPanelItem extends StatefulWidget {
  Widget headerWidget;
  Widget bodyWidget;
  UserContact user;

  ExpansionPanelItem({
    required this.headerWidget,
    required this.bodyWidget,
    required this.user,
    super.key,
  });

  @override
  State<StatefulWidget> createState() {
    return _ExpansionPanelItemState();
  }
}

class _ExpansionPanelItemState extends State<ExpansionPanelItem> {
  @override
  Widget build(BuildContext context) {
    final Widget header = GestureDetector(
      onTap: () {
        setState(() {
          widget.user.isExpanded = !widget.user.isExpanded;
        });
      },
      child: Row(
        children: <Widget>[
          Expanded(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 500),
              curve: Curves.fastOutSlowIn,
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  minHeight: Sizes.s48,
                ),
                child: widget.headerWidget,
              ),
            ),
          ),
        ],
      ),
    );

    return Column(
      children: <Widget>[
        header,
        AnimatedCrossFade(
          firstChild: Container(height: 0.0),
          secondChild: widget.bodyWidget,
          firstCurve: const Interval(0.0, 0.6, curve: Curves.fastOutSlowIn),
          secondCurve: const Interval(0.4, 1.0, curve: Curves.fastOutSlowIn),
          sizeCurve: Curves.fastOutSlowIn,
          crossFadeState: widget.user.isExpanded
              ? CrossFadeState.showSecond
              : CrossFadeState.showFirst,
          duration: const Duration(milliseconds: 500),
        ),
      ],
    );
  }
}
