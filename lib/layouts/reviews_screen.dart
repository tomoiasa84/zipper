import 'package:contractor_search/model/review.dart';
import 'package:contractor_search/resources/color_utils.dart';
import 'package:contractor_search/resources/localization_class.dart';
import 'package:contractor_search/utils/general_methods.dart';
import 'package:contractor_search/utils/general_widgets.dart';
import 'package:contractor_search/utils/star_display.dart';
import 'package:flutter/material.dart';

class ReviewsScreen extends StatefulWidget {
  final List<Review> reviews;

  const ReviewsScreen({Key key, this.reviews}) : super(key: key);

  @override
  ReviewsScreenState createState() => ReviewsScreenState();
}

class ReviewsScreenState extends State<ReviewsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: widget.reviews.isNotEmpty
          ? _buildBody()
          : Center(
              child: Text(
                Localization.of(context).getString('emptyReviewsList'),
                style: TextStyle(
                    fontSize: 18.0, color: ColorUtils.lightGray30Opacity),
              ),
            ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      title: Text(
        Localization.of(context).getString('reviews'),
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
      ),
      centerTitle: true,
      leading: buildBackButton(Icons.arrow_back, () {
        Navigator.pop(context);
      }),
    );
  }

  Widget _buildBody() {
    return ListView.builder(
        shrinkWrap: true,
        primary: false,
        itemCount: widget.reviews.length,
        itemBuilder: (BuildContext context, int index) {
          return Container(
              margin: EdgeInsets.only(
                top: (index == 0) ? 16.0 : 0.0,
                bottom: (index == widget.reviews.length - 1) ? 24.0 : 0.0,
              ),
              child: _buildReviewItem(widget.reviews.elementAt(index)));
        });
  }

  Widget _buildReviewItem(Review review) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16.0, 26.0, 16.0, 31.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              _buildRating(review),
              _buildDecription(review),
              _buildAuthor(review)
            ],
          ),
        ),
      ),
    );
  }

  Row _buildRating(Review review) {
    return Row(
      children: <Widget>[
        Text(
          Localization.of(context).getString(getReviewQualifier(review)),
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 16.0),
          child: StarDisplay(
            value: review.stars,
          ),
        ),
      ],
    );
  }

  Padding _buildDecription(Review review) {
    return Padding(
      padding: const EdgeInsets.only(top: 18.0, bottom: 16.0),
      child: Text.rich(
        TextSpan(
          children: <TextSpan>[
            TextSpan(
                text: '#' + review.userTag.tag.name + ' ',
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: ColorUtils.orangeAccent)),
            TextSpan(
                text: review.text,
                style: TextStyle(color: ColorUtils.lightGray, height: 1.5)),
          ],
        ),
        textAlign: TextAlign.start,
      ),
    );
  }

  Row _buildAuthor(Review review) {
    return Row(
      children: <Widget>[
        Container(
          margin: EdgeInsets.only(
            right: 8.0,
          ),
          width: 24,
          height: 24,
          decoration: new BoxDecoration(
            shape: BoxShape.circle,
          ),
          child: CircleAvatar(
            child: review.author.profilePicUrl == null ||
                    review.author.profilePicUrl.isEmpty
                ? Text(
                    review.author.name.startsWith('+')
                        ? '+'
                        : getInitials(review.author.name),
                    style: TextStyle(color: ColorUtils.darkerGray))
                : null,
            backgroundImage: review.author.profilePicUrl != null &&
                    review.author.profilePicUrl.isNotEmpty
                ? NetworkImage(review.author.profilePicUrl)
                : null,
            backgroundColor: ColorUtils.getColorForName(review.author.name)
          ),
        ),
        Text(review.author.name,
            style: TextStyle(
                color: ColorUtils.darkGray, fontWeight: FontWeight.bold))
      ],
    );
  }
}
