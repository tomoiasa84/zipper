import 'package:auto_size_text/auto_size_text.dart';
import 'package:contractor_search/bloc/home_bloc.dart';
import 'package:contractor_search/layouts/card_details_screen.dart';
import 'package:contractor_search/layouts/send_in_chat_screen.dart';
import 'package:contractor_search/layouts/user_details_screen.dart';
import 'package:contractor_search/model/card.dart';
import 'package:contractor_search/model/user.dart';
import 'package:contractor_search/resources/color_utils.dart';
import 'package:contractor_search/resources/localization_class.dart';
import 'package:contractor_search/utils/general_methods.dart';
import 'package:contractor_search/utils/search_card_utils.dart';
import 'package:flutter/material.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';

import 'my_profile_screen.dart';

class HomeScreen extends StatefulWidget {
  final List<CardModel> cards;
  final Function onCardsUpdated;

  const HomeScreen({Key key, this.cards, this.onCardsUpdated}) : super(key: key);

  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  var _saving = false;
  HomeBloc _homeBloc = HomeBloc();
  List<CardModel> _cardsList = [];

  @override
  void initState() {
    _cardsList = widget.cards;
    if (_cardsList.isEmpty) {
      getCards();
    }
    super.initState();
  }

  @override
  void dispose() {
    _homeBloc.dispose();
    super.dispose();
  }

  void getCards() {
    if (mounted) {
      setState(() {
        _saving = true;
      });
    }
    _homeBloc.getUserByIdWithCardsConnections();
    _homeBloc.getUserByIdWithCardsConnectionsObservable.listen((result) {
      if (result.errors == null) {
        User currentUser = User.fromJson(result.data['get_user']);
        List<CardModel> newCardsList = [];
        newCardsList.addAll(currentUser.cardsConnections);
        newCardsList.addAll(currentUser.cards);
        newCardsList.sort(sortCardsByTime);
        widget.onCardsUpdated(newCardsList);
        setState(() {
          _cardsList = newCardsList;
          _saving = false;
        });
      } else {
        if (mounted) {
          setState(() {
            _saving = false;
          });
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return ModalProgressHUD(
      progressIndicator: CircularProgressIndicator(
        valueColor: new AlwaysStoppedAnimation<Color>(ColorUtils.orangeAccent),
      ),
      inAsyncCall: _saving,
      child: Scaffold(
        appBar: _buildAppBar(),
        body: _cardsList.isNotEmpty
            ? _buildContent()
            : (_saving
                ? Container()
                : Center(
                    child: Text(
                        Localization.of(context).getString('emptyPostsList')),
                  )),
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
        title: Text(
          Localization.of(context).getString('home'),
          style: TextStyle(
            fontFamily: 'Arial',
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
        centerTitle: true,
        actions: <Widget>[
          IconButton(
            icon: Icon(
              Icons.search,
              color: ColorUtils.darkerGray,
            ),
            onPressed: () {
              showSearch(
                  context: context,
                  delegate: SearchCard(_cardsList, (card) {
                    _goToCardDetailsScreen(card);
                  }, (card) {
                    _goToSendInChatScreen(card);
                  }, Localization.of(context).getString('isLookingFor'),
                      Localization.of(context).getString('sendInChat')));
            },
          )
        ]);
  }

  ListView _buildContent() {
    return ListView.builder(
        itemCount: _cardsList?.length ?? 0,
        itemBuilder: (BuildContext context, int index) {
          CardModel card = _cardsList.elementAt(index);
          return Container(
              margin: EdgeInsets.only(
                  top: (index == 0) ? 16.0 : 0.0,
                  bottom: (index == _cardsList.length - 1) ? 16.0 : 0.0,
                  left: 16.0,
                  right: 16.0),
              child: _buildCardItem(card));
        });
  }

  Widget _buildCardItem(CardModel card) {
    return GestureDetector(
      onTap: () {
        _goToCardDetailsScreen(card);
      },
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: Stack(
          children: <Widget>[
            Padding(
              padding:
                  const EdgeInsets.symmetric(vertical: 24.0, horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  _buildCardText(card),
                  _buildCreatedAtInfo(card)
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Row _buildCardText(CardModel card) {
    return Row(
      children: <Widget>[
        CircleAvatar(
          child: card.postedBy.profilePicUrl == null ||
                  card.postedBy.profilePicUrl.isEmpty
              ? Text(
                  card.postedBy.name.startsWith('+')
                      ? '+'
                      : getInitials(card.postedBy.name),
                  style: TextStyle(color: ColorUtils.darkerGray))
              : null,
          backgroundImage: card.postedBy.profilePicUrl != null &&
                  card.postedBy.profilePicUrl.isNotEmpty
              ? NetworkImage(card.postedBy.profilePicUrl)
              : null,
          backgroundColor: ColorUtils.lightLightGray,
        ),
        Flexible(
          child: Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    GestureDetector(
                      onTap: () {
                        getCurrentUserId().then((currentUserId) async {
                          if (currentUserId == card.postedBy.id) {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => MyProfileScreen(
                                        isStartedFromHomeScreen: false)));
                          } else {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => UserDetailsScreen(
                                        user: card.postedBy,
                                        ))).then((_) {
                              getCards();
                            });
                          }
                        });
                      },
                      child: Text(card.postedBy.name,
                          style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                    Text(Localization.of(context).getString("isLookingFor"),
                        style: TextStyle(color: ColorUtils.darkerGray))
                  ],
                ),
                Text(
                  "#" + card.searchFor.name,
                  overflow: TextOverflow.clip,
                  style: TextStyle(
                      color: ColorUtils.orangeAccent,
                      fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        )
      ],
    );
  }

  Padding _buildCreatedAtInfo(CardModel card) {
    String difference = getTimeDifference(card.createdAt);
    return Padding(
      padding: const EdgeInsets.only(top: 16.0),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Row(
              children: <Widget>[
                Image.asset('assets/images/ic_access_time.png'),
                Padding(
                  padding: const EdgeInsets.only(left: 4.0, right: 8.0),
                  child: AutoSizeText(
                    difference + ' ago',
                    style: TextStyle(color: ColorUtils.darkerGray),
                  ),
                ),
                Image.asset('assets/images/ic_replies_gray.png'),
                Padding(
                  padding: const EdgeInsets.only(left: 4.0, right: 8.0),
                  child: AutoSizeText(
                    card.recommendsCount.toString(),
                    style: TextStyle(color: ColorUtils.darkerGray),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () {
              _goToSendInChatScreen(card);
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                AutoSizeText(
                  Localization.of(context).getString('sendInChat'),
                  style: TextStyle(
                      fontSize: 14,
                      color: ColorUtils.orangeAccent,
                      fontWeight: FontWeight.bold),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 4.0),
                  child: Icon(
                    Icons.send,
                    color: ColorUtils.orangeAccent,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _goToCardDetailsScreen(CardModel card) async {
    await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => CardDetailsScreen(cardId: card.id)));
    getCards();
  }

  void _goToSendInChatScreen(card) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => SendInChatScreen(cardModel: card)));
  }
}
