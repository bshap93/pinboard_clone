import 'package:flutter/material.dart';
import 'package:pinboard_clone/ui/api_serviced_views/recent_pins/recent_pins_viewmodel.dart';
import 'package:stacked/stacked.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../models/pinboard_pin/pinboard_pin.dart';
import '../pinboard_pin/pinboard_pin_view.dart';

// Line 53 and 90 have commented out yet important code.

class RecentPinsView extends StatefulWidget {
  const RecentPinsView({Key? key}) : super(key: key);

  @override
  State<RecentPinsView> createState() => _RecentPinsViewState();
}

class _RecentPinsViewState extends State<RecentPinsView> {
  Widget _getInformationMessage(String message) {
    return Center(
        child: Text(
      message,
      textAlign: TextAlign.center,
      style: TextStyle(fontWeight: FontWeight.w900, color: Colors.grey[500]),
    ));
  }

  // persist URL state across views
  List<PinboardPin> myRecentPosts = [];
  // Create a Picker object to filter by tags

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<RecentPinsViewModel>.reactive(
        viewModelBuilder: () => RecentPinsViewModel(),
        builder: (context, model, _) {
          // Tag noneTag = model.getTagByName("None");
          return Scaffold(
              appBar: AppBar(title: Text("Recent Pins")),
              body: FutureBuilder(
                  future: model.recent_pins,
                  builder: (BuildContext context,
                      AsyncSnapshot<List<PinboardPin>> snapshot) {
                    if (!snapshot.hasData) {
                      // while data is loading:
                      // ignore: prefer_const_constructors
                      return Center(
                        child: const CircularProgressIndicator(),
                      );
                    } else if (snapshot.hasError) {
                      return _getInformationMessage(snapshot.error.toString());
                    }
                    // data loaded:
                    var myRecentPosts = snapshot.data;

                    // ignore: prefer_is_empty
                    if (myRecentPosts?.length == 0) {
                      return _getInformationMessage(
                          'No data found for your account. Add something and check back.');
                    }

                    return ListView(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      children: [
                        if (myRecentPosts!.isEmpty) _showEmptyPage(),
                        ...myRecentPosts.map((post) {
                          TextEditingController description_controller =
                              TextEditingController(text: post.description);
                          return Card(
                              child: ListTile(
                            title: Column(
                              children: [
                                TextField(
                                  // See above
                                  controller: description_controller,
                                  // ignore: deprecated_member_use
                                  onTap: () => {
                                    if (post.href == null)
                                      {
                                        // ignore: deprecated_member_use
                                        launch("https://www.google.com"),
                                      }
                                    else
                                      // ignore: deprecated_member_use
                                      {launch("https://" + post.href)}
                                  },
                                  decoration: null,
                                  focusNode: AlwaysDisabledFocusNode(),
                                  maxLines: 2,
                                  style: const TextStyle(
                                    color: Colors.blue,
                                    fontSize: 20,
                                  ),
                                ),
                              ],
                            ),
                            // ignore: prefer_const_constructors
                            trailing: IconButton(
                              // ignore: prefer_const_constructors
                              icon: Icon(
                                Icons.arrow_forward,
                              ),
                              onPressed: () {},
                              // onPressed: () => Navigator.push(
                              //     context,
                              //     MaterialPageRoute(
                              //         builder: (context) => {},
                              //             // PinboardPinView(post.href)))),
                            ),
                          ));
                        })
                      ],
                    );
                  }));
        });
  }

  // End of build method. Below are the other methods

  _showEmptyPage() {
    return Opacity(
      opacity: 0.5,
      child: Column(
        children: const [
          SizedBox(height: 64),
          Icon(Icons.emoji_food_beverage_outlined, size: 48),
          SizedBox(height: 16),
          Text(
            'No pins yet. Click + below to add a new one. \n\n Click # above to select a tag.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14),
          ),
        ],
      ),
    );
  }
}

class AlwaysDisabledFocusNode extends FocusNode {
  @override
  bool get hasFocus => false;
}