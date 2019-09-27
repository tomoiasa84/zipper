import 'package:auto_size_text/auto_size_text.dart';
import 'package:contractor_search/bloc/home_content_bloc.dart';
import 'package:contractor_search/layouts/post_details_screen.dart';
import 'package:contractor_search/model/card.dart';
import 'package:contractor_search/resources/color_utils.dart';
import 'package:contractor_search/resources/localization_class.dart';
import 'package:contractor_search/utils/general_methods.dart';
import 'package:flutter/material.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';

class HomeContentScreen extends StatefulWidget {
  @override
  HomeContentScreenState createState() => HomeContentScreenState();
}

class HomeContentScreenState extends State<HomeContentScreen> {
  var _saving = false;
  HomeContentBloc _homeContentBloc;
  List<CardModel> _postsList = [];

  @override
  void initState() {
    getPosts();
    super.initState();
  }

  void getPosts() {
    if (mounted) {
      setState(() {
        _saving = true;
      });
    }
    _homeContentBloc = HomeContentBloc();
    _homeContentBloc.getPosts().then((result) {
      if (result.errors == null) {
        final List<Map<String, dynamic>> posts =
            result.data['get_cards'].cast<Map<String, dynamic>>();
        posts.forEach((item) {
          _postsList.add(CardModel.fromJson(item));
        });
        _postsList = _postsList.reversed.toList();
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
      inAsyncCall: _saving,
      child: Scaffold(
        appBar: _buildAppBar(),
        body: _postsList.isNotEmpty
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
          style: TextStyle(fontFamily: 'Arial', fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: <Widget>[
          IconButton(
            icon: Icon(
              Icons.search,
              color: ColorUtils.darkerGray,
            ),
            onPressed: () {},
          )
        ]);
  }

  ListView _buildContent() {
    return ListView.builder(
        itemCount: _postsList?.length ?? 0,
        itemBuilder: (BuildContext context, int index) {
          CardModel post = _postsList.elementAt(index);
          return Container(
              margin: EdgeInsets.only(
                  top: (index == 0) ? 16.0 : 0.0,
                  bottom: (index == _postsList.length - 1) ? 16.0 : 0.0,
                  left: 16.0,
                  right: 16.0),
              child: _buildPostItem(post));
        });
  }

  Widget _buildPostItem(CardModel post) {
    return Card(
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
                _buildPostText(post),
                _buildCreatedAtInfo(post.createdAt)
              ],
            ),
          ),
        ],
      ),
    );
  }

  Row _buildPostText(CardModel post) {
    return Row(
      children: <Widget>[
        CircleAvatar(
          child: Text(getInitials(post.postedBy.name),
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
                        text: post.postedBy.name,
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    TextSpan(
                        text:
                            Localization.of(context).getString("isLookingFor"),
                        style: TextStyle(color: ColorUtils.darkerGray)),
                  ],
                ),
                textAlign: TextAlign.center,
              ),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => PostDetailsScreen(
                                post: post,
                              )));
                },
                child: Text(
                  "#" + post.searchFor.name,
                  style: TextStyle(
                      color: ColorUtils.orangeAccent,
                      fontWeight: FontWeight.bold),
                ),
              )
            ],
          ),
        )
      ],
    );
  }

  Padding _buildCreatedAtInfo(String createdAt) {
    String difference = getTimeDifference(createdAt);
    return Padding(
      padding: const EdgeInsets.only(top: 16.0),
      child: Row(
        children: <Widget>[
          Row(
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
                  '3 replies',
                  style: TextStyle(color: ColorUtils.darkerGray),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          Flexible(
            flex: 1,
            child: GestureDetector(
              onTap: () {},
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
          ),
        ],
      ),
    );
  }
}
