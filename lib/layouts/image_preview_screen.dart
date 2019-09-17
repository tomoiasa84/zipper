import 'package:contractor_search/resources/color_utils.dart';
import 'package:contractor_search/resources/localization_class.dart';
import 'package:flutter/material.dart';

class ImagePreviewScreen extends StatefulWidget {
  final String imageDownloadUrl;

  const ImagePreviewScreen({Key key, this.imageDownloadUrl}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return ImagePreviewScreenState();
  }
}

class ImagePreviewScreenState extends State<ImagePreviewScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: new Column(children: <Widget>[
        AppBar(
          title: Text(Localization.of(context).getString('imagePreview'),
              style: TextStyle(
                  color: ColorUtils.textBlack,
                  fontSize: 14,
                  fontFamily: 'Arial',
                  fontWeight: FontWeight.bold)),
          centerTitle: true,
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back,
              color: ColorUtils.almostBlack,
            ),
            onPressed: () => Navigator.pop(context, false),
          ),
          backgroundColor: Colors.white,
        ),
        Flexible(
            child: Container(
          decoration: new BoxDecoration(
              shape: BoxShape.rectangle,
              image: widget.imageDownloadUrl == null
                  ? null
                  : DecorationImage(
                      fit: BoxFit.contain,
                      image: new NetworkImage(widget.imageDownloadUrl == null
                          ? null
                          : widget.imageDownloadUrl))),
        ))
      ]),
    );
  }
}
