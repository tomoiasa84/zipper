import 'package:contractor_search/model/leave_review_model.dart';
import 'package:contractor_search/resources/color_utils.dart';
import 'package:contractor_search/resources/localization_class.dart';
import 'package:contractor_search/utils/star_rating.dart';
import 'package:flutter/material.dart';

class LeaveReviewDialog extends StatefulWidget {
  const LeaveReviewDialog({Key key}) : super(key: key);

  @override
  LeaveReviewDialogState createState() {
    return LeaveReviewDialogState();
  }
}

class LeaveReviewDialogState extends State<LeaveReviewDialog> {
  var rating = 0;

  TextEditingController _reviewDetailsController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      elevation: 1.0,
      backgroundColor: Colors.transparent,
      child: dialogContent(context),
    );
  }

  dialogContent(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
      decoration: new BoxDecoration(
        color: Colors.white,
        shape: BoxShape.rectangle,
        borderRadius: BorderRadius.circular(10.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 10.0,
            offset: const Offset(0.0, 10.0),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Expanded(
                child: Text(
                  Localization.of(context).getString("leaveReview"),
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              StarRating(
                onChanged: (index) {
                  setState(() {
                    rating = index;
                  });
                },
                value: rating,
              )
            ],
          ),
          Flexible(
            flex: 1,
            child: Padding(
              padding: const EdgeInsets.only(top: 21.0),
              child: TextFormField(
                controller: _reviewDetailsController,
                maxLines: 5,
                style: TextStyle(color: ColorUtils.darkGray, height: 1.5),
                textAlign: TextAlign.justify,
                onChanged: (value) {},
                decoration: InputDecoration(
                  hintText: Localization.of(context).getString('typeAMessage'),
                  border: InputBorder.none,
                ),
              ),
            ),
          ),
          GestureDetector(
            onTap: () {
              Navigator.pop(context,
                  LeaveReviewModel(_reviewDetailsController.text, rating));
            },
            child: Container(
              alignment: Alignment.centerRight,
              child: Text(
                Localization.of(context).getString("publishReview"),
                style: TextStyle(
                    color: ColorUtils.orangeAccent,
                    fontWeight: FontWeight.bold),
              ),
            ),
          )
        ],
      ),
    );
  }
}
