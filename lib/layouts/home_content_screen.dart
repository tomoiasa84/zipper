import 'package:auto_size_text/auto_size_text.dart';
import 'package:contractor_search/bloc/home_content_bloc.dart';
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
import 'account_screen.dart';
class HomeContentScreen extends StatefulWidget {
  final User user;
  final Function onUserUpdated;
  const HomeContentScreen({Key key, this.user, this.onUserUpdated})
      : super(key: key);
  @override
  HomeContentScreenState createState() => HomeContentScreenState();
}
class HomeContentScreenState extends State<HomeContentScreen> {
  var _saving = false;
  HomeContentBloc _homeContentBloc = HomeContentBloc();
  List<CardModel> _cardsList = [];
  Stopwatch stopwatch = Stopwatch();

  @override
  void initState() {
    stopwatch.start();
    if (widget.user != null && widget.user.cardsConnections != null) {
      _cardsList.clear();
      _cardsList.addAll(widget.user.cardsConnections);
      _cardsList.addAll(widget.user.cards);
      _cardsList.sort((a, b) {
        DateTime dateA = parseDateFromString(a.createdAt);
        DateTime dateB = parseDateFromString(b.createdAt);
        return dateB.compareTo(dateA);
      });
      _homeContentBloc.getUserByIdWithCardsConnections().then((result) {
        if (result.errors == null && mounted) {
          User currentUser = User.fromJson(result.data['get_user']);
          widget.onUserUpdated(currentUser.cardsConnections, currentUser.cards);
          if (currentUser != null && currentUser.cardsConnections != null) {
            if (_cardsList != currentUser.cardsConnections) {
              _cardsList.clear();
              _cardsList.addAll(currentUser.cardsConnections);
              _cardsList.addAll(currentUser.cards);
              if (mounted) {
                setState(() {
                  _cardsList.sort((a, b) {
                    DateTime dateA = parseDateFromString(a.createdAt);
                    DateTime dateB = parseDateFromString(b.createdAt);
                    return dateB.compareTo(dateA);
                  });
                });
              }
            }
          }
        } else {
          if (mounted) {
            setState(() {
              _saving = false;
            });
          }
        }
      });
    } else {
      if (mounted) {
        setState(() {
          _saving = true;
        });
      }
      getCards();
    }
    super.initState();
  }
  void getCards() {
    print("getCards() called");
    _homeContentBloc = HomeContentBloc();
    _homeContentBloc.getUserByIdWithCardsConnections().then((result) {
      if (result.errors == null && mounted) {
        print("getCards() result");
        User currentUser = User.fromJson(result.data['get_user']);
        List<CardModel> newCardsList = [];
        newCardsList.addAll(currentUser.cardsConnections);
        newCardsList.addAll(currentUser.cards);
        newCardsList.sort((a, b) {
          DateTime dateA = parseDateFromString(a.createdAt);
          DateTime dateB = parseDateFromString(b.createdAt);
          return dateB.compareTo(dateA);
        });
        widget.onUserUpdated(currentUser.cardsConnections, currentUser.cards);
        if (currentUser != null && currentUser.cardsConnections != null) {
          if(mounted) {
            setState(() {
              _cardsList = newCardsList;
              _saving = false;
              print('Finished getCards overall in: ${stopwatch.elapsed}');
            });
          }
        } else {
          if(mounted) {
            setState(() {
              _saving = false;
            });
          }
        }
      } else {
        if(mounted) {
          setState(() {
            _saving = false;
          });
        }
      }
    });
  }
  @override
  Widget build(BuildContext context) {
    print("build() called");
    return ModalProgressHUD(
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
    print("buildAppBar() called");
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
                                    builder: (context) => AccountScreen(
                                        isStartedFromHomeScreen: false)));
                          } else {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => UserDetailsScreen(
                                        user: card.postedBy,
                                        currentUser: widget.user))).then((_) {
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