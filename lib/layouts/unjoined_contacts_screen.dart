import 'package:contractor_search/model/unjoined_contacts_model.dart';
import 'package:contractor_search/resources/color_utils.dart';
import 'package:contractor_search/resources/localization_class.dart';
import 'package:contractor_search/utils/general_methods.dart';
import 'package:contractor_search/utils/general_widgets.dart';
import 'package:flutter/material.dart';

class UnjoinedContactsScreen extends StatefulWidget {
  final List<UnjoinedContactsModel> unjoinedContacts;

  const UnjoinedContactsScreen({Key key, this.unjoinedContacts})
      : super(key: key);

  @override
  UnjoinedContactsScreenState createState() => UnjoinedContactsScreenState();
}

class UnjoinedContactsScreenState extends State<UnjoinedContactsScreen> {
  bool _allContactsSelected;

  @override
  void initState() {
    _setAllContactsSelectedState();
    super.initState();
  }

  void _setAllContactsSelectedState() {
    var i = 0;
    for (var unjoinedContact in widget.unjoinedContacts) {
      if (unjoinedContact.selected) {
        i += 1;
        break;
      }
    }
    setState(() {
      _allContactsSelected = i > 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Expanded(
            child: widget.unjoinedContacts.isNotEmpty
                ? _buildUntaggedContactsList()
                : Center(
                    child: Text(
                        Localization.of(context).getString("emptyUsersList")),
                  ),
          ),
        ],
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      title: Text(
        Localization.of(context).getString("contacts"),
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.0),
      ),
      centerTitle: true,
      leading: buildBackButton(Icons.arrow_back, () {
        Navigator.pop(context, true);
      }),
    );
  }

  Container _buildUntaggedContactsList() {
    return Container(
      child: Column(
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              GestureDetector(
                onTap: _toggleAllContactsSelected,
                child: Text(
                    _allContactsSelected
                        ? Localization.of(context).getString('deselectAll')
                        : Localization.of(context).getString('selectAll'),
                    style:
                        TextStyle(fontSize: 14.0)),
              ),
              Container(
                padding: const EdgeInsets.only(
                    right: 36.0, left: 8.0, top: 16.0, bottom: 16.0),
                alignment: Alignment.centerRight,
                child: GestureDetector(
                  onTap: _toggleAllContactsSelected,
                  child: Icon(
                    Icons.check_box,
                    color: _allContactsSelected
                        ? ColorUtils.orangeAccent
                        : ColorUtils.lightLightGray,
                  ),
                ),
              )
            ],
          ),
          Flexible(
            child: ListView.builder(
                itemCount: widget.unjoinedContacts.length,
                itemBuilder: (BuildContext context, int index) {
                  return Container(
                      margin: EdgeInsets.only(
                          top: 0,
                          bottom: (index == widget.unjoinedContacts.length - 1)
                              ? 24.0
                              : 0.0,
                          left: 16.0,
                          right: 16.0),
                      child: _buildListItem(
                          widget.unjoinedContacts.elementAt(index)));
                }),
          )
        ],
      ),
    );
  }

  void _toggleAllContactsSelected() {
    setState(() {
      _allContactsSelected = !_allContactsSelected;
      for (var unjoinedContact in widget.unjoinedContacts) {
        unjoinedContact.selected = _allContactsSelected;
      }
    });
  }

  Card _buildListItem(UnjoinedContactsModel unjoinedContact) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: Container(
        padding: const EdgeInsets.only(left: 16.0, top: 16.0, bottom: 16.0),
        child: Row(
          children: <Widget>[
            (unjoinedContact.contact.avatar != null &&
                    unjoinedContact.contact.avatar.length > 0)
                ? CircleAvatar(
                    backgroundImage:
                        MemoryImage(unjoinedContact.contact.avatar))
                : CircleAvatar(
                    child: Text(
                        getInitials(unjoinedContact.contact.displayName),
                        style: TextStyle(color: ColorUtils.darkerGray)),
                    backgroundColor: ColorUtils.lightLightGray,
                  ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: Text(
                  unjoinedContact.contact.displayName,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.only(
                  right: 16.0, left: 16.0, top: 8.0, bottom: 8.0),
              alignment: Alignment.centerRight,
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    unjoinedContact.selected = !unjoinedContact.selected;
                  });
                },
                child: Icon(
                  Icons.check_box,
                  color: unjoinedContact.selected
                      ? ColorUtils.orangeAccent
                      : ColorUtils.lightLightGray,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
