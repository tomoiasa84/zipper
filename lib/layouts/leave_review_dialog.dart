import 'package:contractor_search/bloc/review_bloc.dart';
import 'package:contractor_search/model/user_tag.dart';
import 'package:contractor_search/resources/color_utils.dart';
import 'package:contractor_search/resources/localization_class.dart';
import 'package:contractor_search/utils/star_rating.dart';
import 'package:flutter/material.dart';

class LeaveReviewDialog extends StatefulWidget {

  final UserTag userTag;
  final String userId;

  const LeaveReviewDialog({Key key, this.userTag, this.userId}) : super(key: key);

  @override
  LeaveReviewDialogState createState() {
    return LeaveReviewDialogState();
  }
}

class LeaveReviewDialogState extends State<LeaveReviewDialog> {
  var rating = 0;

  ReviewBloc _reviewBloc;

  TextEditingController _reviewDetailsController = TextEditingController();

  @override
  void initState() {
    _reviewBloc = ReviewBloc();
    super.initState();
  }

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
          Padding(
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
          GestureDetector(
            onTap: () {
              postReview();
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

  void postReview() {
    _reviewBloc.createReview(widget.userId, widget.userTag.id, rating, _reviewDetailsController.text).then((result){
      if(result.errors == null){
        Navigator.of(context).pop(Localization.of(context).getString("yourReviewWasSuccessfullyAdded"));
      }
      else{
        Navigator.of(context).pop(result.errors[0].message);
      }
    });
  }
}
