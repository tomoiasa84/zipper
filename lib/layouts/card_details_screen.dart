import 'package:contractor_search/layouts/recommend_friend_screen.dart';
import 'package:contractor_search/model/card.dart';
import 'package:contractor_search/resources/color_utils.dart';
import 'package:contractor_search/resources/localization_class.dart';
import 'package:contractor_search/utils/general_methods.dart';
import 'package:contractor_search/utils/general_widgets.dart';
import 'package:flutter/material.dart';

class CardDetailsScreen extends StatefulWidget {
  final CardModel card;

  const CardDetailsScreen({Key key, this.card}) : super(key: key);

  @override
  CardDetailsScreenState createState() => CardDetailsScreenState();
}

class CardDetailsScreenState extends State<CardDetailsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: _buildContent(),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      title: Text(
        Localization.of(context).getString('post'),
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      centerTitle: true,
      leading: buildBackButton(Icons.arrow_back, () {
        Navigator.pop(context);
      }),
    );
  }

  Widget _buildContent() {
    return SingleChildScrollView(
      child: Column(
        children: <Widget>[
          _buildCardDetails(),
        ],
      ),
    );
  }

  Padding _buildCardDetails() {
    return Padding(
      padding: const EdgeInsets.only(top: 16.0, left: 16.0, right: 16.0),
      child: Stack(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(bottom: 20.0),
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16.0, 24.0, 16.0, 54.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    _buildCardText(),
                    _buildDetailsText(),
                    _buildCreatedAtInfo(),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
              bottom: 0.0,
              right: 0.0,
              left: 0.0,
              child: _buildRecommendButton())
        ],
      ),
    );
  }

  Row _buildCardText() {
    return Row(
      children: <Widget>[
        CircleAvatar(
          child: Text(getInitials(widget.card.postedBy.name),
              style: TextStyle(color: ColorUtils.darkerGray)),
          backgroundColor: ColorUtils.lightLightGray,
        ),
        Padding(
          padding: const EdgeInsets.only(left: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text.rich(
                TextSpan(
                  children: <TextSpan>[
                    TextSpan(
                        text: widget.card.postedBy.name,
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    TextSpan(
                        text:
                            Localization.of(context).getString("isLookingFor"),
                        style: TextStyle(color: ColorUtils.darkerGray)),
                  ],
                ),
                textAlign: TextAlign.center,
              ),
              Text(
                "#" + widget.card.searchFor.name,
                style: TextStyle(
                    color: ColorUtils.orangeAccent,
                    fontWeight: FontWeight.bold),
              )
            ],
          ),
        )
      ],
    );
  }

  Padding _buildCreatedAtInfo() {
    String difference = getTimeDifference(widget.card.createdAt);
    return Padding(
      padding: const EdgeInsets.only(top: 16.0),
      child: Row(
        children: <Widget>[
          Image.asset('assets/images/ic_access_time.png'),
          Padding(
            padding: const EdgeInsets.only(left: 4.0, right: 16.0),
            child: Text(
              difference + ' ago',
              style: TextStyle(color: ColorUtils.darkerGray),
            ),
          ),
          Image.asset('assets/images/ic_replies_gray.png'),
          Padding(
            padding: const EdgeInsets.only(left: 4.0, right: 16.0),
            child: Text('3 replies',
                style: TextStyle(
                  color: ColorUtils.darkerGray,
                )),
          ),
        ],
      ),
    );
  }

  Padding _buildDetailsText() {
    return Padding(
      padding: const EdgeInsets.only(top: 16.0),
      child: (widget.card.text != null && widget.card.text.isNotEmpty)
          ? Text(
              widget.card.text,
              style: TextStyle(color: ColorUtils.darkerGray, height: 1.5),
            )
          : Container(),
    );
  }

  GestureDetector _buildRecommendButton() {
    return GestureDetector(
      onTap: (){
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => RecommendFriendScreen(searchedTag: widget.card.searchFor
                )));
      },
      child: Container(
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10.0),
              color: ColorUtils.orangeAccent),
          margin: const EdgeInsets.symmetric(horizontal: 27.0),
          child: Padding(
            padding: const EdgeInsets.all(18.0),
            child: Text(
              Localization.of(context).getString("tapAndRecommendAFriend"),
              textAlign: TextAlign.center,
              style: TextStyle(
                color: ColorUtils.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          )),
    );
  }
}
