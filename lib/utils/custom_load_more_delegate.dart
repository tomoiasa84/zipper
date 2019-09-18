import 'package:contractor_search/resources/localization_class.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:loadmore/loadmore.dart';

class CustomLoadMoreDelegate extends LoadMoreDelegate {
  BuildContext _context;

  CustomLoadMoreDelegate(BuildContext context) {
    _context = context;
  }

  @override
  double widgetHeight(LoadMoreStatus status) =>
      status == LoadMoreStatus.nomore ? 0 : _defaultLoadMoreHeight;

  @override
  Widget buildChild(LoadMoreStatus status,
      {LoadMoreTextBuilder builder = DefaultLoadMoreTextBuilder.chinese}) {
    String text = Localization.of(_context).getString(status.toString());

    if (status == LoadMoreStatus.fail) {
      return Container(
        child: Text(text),
      );
    }
    if (status == LoadMoreStatus.loading) {
      return Container(
        alignment: Alignment.center,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            SizedBox(
              width: _loadMoreIndicatorSize,
              height: _loadMoreIndicatorSize,
              child: CircularProgressIndicator(
                backgroundColor: Colors.blue,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(text),
            ),
          ],
        ),
      );
    }
    return Container();
  }
}

const _loadMoreIndicatorSize = 33.0;
const _defaultLoadMoreHeight = 80.0;
