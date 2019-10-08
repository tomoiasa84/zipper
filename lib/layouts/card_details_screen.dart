import 'package:contractor_search/bloc/card_details_bloc.dart';
import 'package:contractor_search/layouts/account_screen.dart';
import 'package:contractor_search/layouts/recommend_friend_screen.dart';
import 'package:contractor_search/layouts/user_details_screen.dart';
import 'package:contractor_search/model/card.dart';
import 'package:contractor_search/model/user.dart';
import 'package:contractor_search/resources/color_utils.dart';
import 'package:contractor_search/resources/localization_class.dart';
import 'package:contractor_search/utils/general_methods.dart';
import 'package:contractor_search/utils/general_widgets.dart';
import 'package:flutter/material.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:intl/intl.dart';
import 'chat_screen.dart';

class CardDetailsScreen extends StatefulWidget {
  final int cardId;

  const CardDetailsScreen({Key key, this.cardId}) : super(key: key);

  @override
  CardDetailsScreenState createState() => CardDetailsScreenState();
}

class CardDetailsScreenState extends State<CardDetailsScreen> {
  CardModel _card;
  CardDetailsBloc _cardDetailsBloc;
  bool _saving = false;

  String _currentUserId;

  @override
  void initState() {
    getCurrentCard();
    getCurrentUserId().then((currentUserId) {
      setState(() {
        _currentUserId = currentUserId;
      });
    });
    super.initState();
  }

  void getCurrentCard() {
    _cardDetailsBloc = CardDetailsBloc();
    setState(() {
      _saving = true;
    });
    _cardDetailsBloc.getCardById(widget.cardId).then((result) {
      if (result.errors == null && mounted) {
        setState(() {
          _saving = false;
          _card = CardModel.fromJson(result.data['get_card']);
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return ModalProgressHUD(
      inAsyncCall: _saving,
      child: Scaffold(
        appBar: _buildAppBar(),
        body: _buildContent(),
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      title: Text(
        Localization.of(context).getString('post'),
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

  Widget _buildContent() {
    return _card != null
        ? SingleChildScrollView(
            child: Column(
              children: <Widget>[
                _buildCardDetails(),
                ListView.builder(
                    shrinkWrap: true,
                    primary: false,
                    itemCount: _card.recommendsList.length,
                    itemBuilder: (BuildContext context, int index) {
                      return Padding(
                        padding: EdgeInsets.only(
                            left: 16.0,
                            right: 16.0,
                            bottom: index == _card.recommendsList.length - 1
                                ? 24.0
                                : 0.0),
                        child: _generateContactUI(index),
                      );
                    })
              ],
            ),
          )
        : Container();
  }

  void _startConversation(User user) {
    _cardDetailsBloc.createConversation(user).then((pubNubConversation) {
      Navigator.of(context).pushReplacement(new MaterialPageRoute(
          builder: (BuildContext context) =>
              ChatScreen(pubNubConversation: pubNubConversation)));
    });
  }

  Widget _generateContactUI(int index) {
    int score = getScoreForSearchedTag(
        _card.recommendsList.elementAt(index).userRecommend.tags,
        _card.recommendsList.elementAt(index).card.searchFor);
    return Container(
      padding: const EdgeInsets.only(top: 16.0),
      child: Column(
        children: <Widget>[
          Stack(
            children: <Widget>[
              Container(
                margin: const EdgeInsets.only(left: 28.0),
                child: Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(48.0, 18.0, 18.0, 16.0),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Expanded(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                _card.recommendsList
                                    .elementAt(index)
                                    .userRecommend
                                    .name,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                    color: ColorUtils.textBlack,
                                    fontWeight: FontWeight.bold),
                              ),
                              Row(
                                children: <Widget>[
                                  Text(
                                    '#' +
                                        _card.recommendsList
                                            .elementAt(index)
                                            .card
                                            .searchFor
                                            .name,
                                    style: TextStyle(
                                        color: ColorUtils.orangeAccent),
                                  ),
                                  score != -1
                                      ? Padding(
                                          padding:
                                              EdgeInsets.fromLTRB(8, 5, 0, 0),
                                          child: Icon(
                                            Icons.star,
                                            color: ColorUtils.darkGray,
                                            size: 16,
                                          ),
                                        )
                                      : Container(),
                                  score != -1
                                      ? Text(score.toString(),
                                          style: TextStyle(
                                              fontSize: 14,
                                              color: ColorUtils.darkGray))
                                      : Container()
                                ],
                              )
                            ],
                          ),
                        ),
                        _card.recommendsList
                                    .elementAt(index)
                                    .userRecommend
                                    .id !=
                                _currentUserId
                            ? Container(
                                decoration: getRoundWhiteCircle(),
                                child: GestureDetector(
                                  onTap: () {
                                    _startConversation(_card.recommendsList
                                        .elementAt(index)
                                        .userRecommend);
                                  },
                                  child: Image.asset(
                                    "assets/images/ic_inbox_circle_accent.png",
                                    color: ColorUtils.messageOrange,
                                  ),
                                ),
                                width: 40,
                                height: 40,
                              )
                            : Container()
                      ],
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 8,
                bottom: 8,
                child: Container(
                  margin: EdgeInsets.fromLTRB(0, 4, 0, 4),
                  width: 56,
                  height: 56,
                  child: CircleAvatar(
                    child: _card.recommendsList
                                .elementAt(index)
                                .userRecommend
                                .profilePicUrl ==
                            null
                        ? Text(
                            getInitials(_card.recommendsList
                                .elementAt(index)
                                .userRecommend
                                .name),
                            style: TextStyle(color: ColorUtils.darkerGray))
                        : null,
                    backgroundImage: _card.recommendsList
                                .elementAt(index)
                                .userRecommend
                                .profilePicUrl !=
                            null
                        ? NetworkImage(_card.recommendsList
                            .elementAt(index)
                            .userRecommend
                            .profilePicUrl)
                        : null,
                    backgroundColor: ColorUtils.lightLightGray,
                  ),
                ),
              ),
            ],
          ),
          Container(
              margin: const EdgeInsets.only(top: 8.0),
              alignment: Alignment.centerRight,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  Text(
                    Localization.of(context).getString('recommendedBy'),
                    style: TextStyle(
                        fontSize: 12.0, color: ColorUtils.almostBlack),
                  ),
                  GestureDetector(
                    onTap: () {
                      getCurrentUserId().then((currentUserId) {
                        if (currentUserId ==
                            _card.recommendsList.elementAt(index).userSend.id) {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => AccountScreen(
                                      isStartedFromHomeScreen: false)));
                        } else {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => UserDetailsScreen(_card
                                      .recommendsList
                                      .elementAt(index)
                                      .userSend
                                      .id)));
                        }
                      });
                    },
                    child: Text(
                      _card.recommendsList.elementAt(index).userSend.name,
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 12.0,
                          color: ColorUtils.almostBlack),
                    ),
                  )
                ],
              )),
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
          child: _card.postedBy.profilePicUrl == null
              ? Text(getInitials(_card.postedBy.name),
                  style: TextStyle(color: ColorUtils.darkerGray))
              : null,
          backgroundImage: _card.postedBy.profilePicUrl != null
              ? NetworkImage(_card.postedBy.profilePicUrl)
              : null,
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
                        text: _card.postedBy.name,
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
                "#" + _card.searchFor.name,
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
    String difference = getTimeDifference(_card.createdAt);
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
            child: Text(
              Intl.plural(
    _card.recommendsCount,
                zero: Localization.of(context).getString('noReplies'),
                one: _card.recommendsCount.toString() + Localization.of(context).getString('reply'),
                two: _card.recommendsCount.toString() + Localization.of(context).getString('replies'),
                few: _card.recommendsCount.toString() + Localization.of(context).getString('replies'),
                many: _card.recommendsCount.toString() + Localization.of(context).getString('replies'),
                other: _card.recommendsCount.toString() + Localization.of(context).getString('replies'),
              ),
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
      child: (_card.text != null && _card.text.isNotEmpty)
          ? Text(
              _card.text,
              style: TextStyle(color: ColorUtils.darkerGray, height: 1.5),
            )
          : Container(),
    );
  }

  GestureDetector _buildRecommendButton() {
    return GestureDetector(
      onTap: () {
        goToRecommendScreen();
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

  Future<void> goToRecommendScreen() async {
    await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => RecommendFriendScreen(card: _card)));

    getCurrentCard();
  }
}
