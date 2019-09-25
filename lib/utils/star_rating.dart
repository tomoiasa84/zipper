import 'package:contractor_search/resources/color_utils.dart';
import 'package:flutter/material.dart';

class StarRating extends StatelessWidget {
  final void Function(int index) onChanged;
  final int value;
  final IconData filledStar;
  final IconData unfilledStar;

  const StarRating({
    Key key,
    @required this.onChanged,
    this.value = 0,
    this.filledStar,
    this.unfilledStar,
  })  : assert(value != null),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).accentColor;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        return GestureDetector(
          onTap: onChanged != null
              ? () {
            onChanged(value == index + 1 ? index : index + 1);
          }
              : null,
          child: Container(
            child: Icon(
              index < value
                  ? filledStar ?? Icons.star
                  : unfilledStar ?? Icons.star_border,
              color: ColorUtils.orangeAccent,
            ),
          ),
        );
      }),
    );
  }
}
