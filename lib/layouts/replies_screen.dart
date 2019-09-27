import 'package:contractor_search/model/card.dart';
import 'package:contractor_search/resources/color_utils.dart';
import 'package:contractor_search/resources/localization_class.dart';
import 'package:contractor_search/utils/general_methods.dart';
import 'package:contractor_search/utils/general_widgets.dart';
import 'package:flutter/material.dart';

class RepliesScreen extends StatefulWidget {
  final CardModel card;

  const RepliesScreen({Key key, this.card}) : super(key: key);

  @override
  RepliesScreenState createState() => RepliesScreenState();
}

class RepliesScreenState extends State<RepliesScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            _buildCardDetails(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: generateContactUI(
                  widget.card.postedBy,
                  widget.card.searchFor.name,
                  () {},
                  Localization.of(context).getString("recommendedBy")),
            ),
            Padding(
              padding:
                  const EdgeInsets.only(left: 16.0, right: 16.0, bottom: 24.0),
              child: generateContactUI(
                  widget.card.postedBy,
                  widget.card.searchFor.name,
                  () {},
                  Localization.of(context).getString("recommendedBy")),
            ),
          ],
        ),
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      centerTitle: true,
      title: Text(
        Localization.of(context).getString('myProfile'),
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      leading: buildBackButton(Icons.arrow_back, () {
        Navigator.pop(context);
      }),
    );
  }

  Padding _buildCardDetails() {
    return Padding(
      padding: const EdgeInsets.only(top: 16.0, left: 16.0, right: 16.0),
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 24.0, horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              _buildPostText(),
              _buildDetailsText(),
              _buildCreatedAtInfo(),
            ],
          ),
        ),
      ),
    );
  }

  Row _buildPostText() {
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
}