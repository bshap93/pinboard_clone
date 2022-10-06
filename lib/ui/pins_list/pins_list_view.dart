import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:filter_list/filter_list.dart';

import '../new_pin/new_pin_view.dart';
import 'pin_card.dart';
import 'pins_list_viewmodel.dart';
import 'package:stacked/stacked.dart';

import '../../models/pinboard_pin/pinboard_pin.dart';
import '../../models/tag/tag.dart';
import '../shared/empty_page.dart';

class PinsListView extends StatefulWidget {
  const PinsListView({Key? key}) : super(key: key);

  @override
  State<PinsListView> createState() => _PinsListViewState();
}

class _PinsListViewState extends State<PinsListView> {
  // persist URL state across views
  List<PinboardPin> myRecentPosts = [];
  late PinsListViewModel mainViewModel;
  int bottomBarSelectedId = 0;
  int numPagesLoaded = 1;
  Tag? currentTag;
  String appBarTitle = "Recent Pins";

  // Create a Picker object to filter by tags
  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<PinsListViewModel>.reactive(
        viewModelBuilder: () => PinsListViewModel(),
        builder: (context, model, _) {
          mainViewModel = model;
          return Scaffold(
            drawer: mainDrawer(model, context),
            appBar: AppBar(
              title: Text(appBarTitle),
              actions: <Widget>[
                IconButton(
                    onPressed: () => executeCurrentTagRemove(),
                    icon: const Icon(Icons.home)),
              ],
            ),
            body: pinsListFutureBuilder(model),
            bottomNavigationBar: BottomAppBar(
              shape: const CircularNotchedRectangle(),
              color: ThemeData.dark().colorScheme.surface,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  IconButton(
                    onPressed: () =>
                        {openFilterDialog(model.tags, <Tag>[], model)},
                    icon: const Icon(Icons.tag),
                  ),
                  IconButton(
                      onPressed: () => {}, icon: const Icon(Icons.search))
                ],
              ),
            ),
            floatingActionButtonLocation:
                FloatingActionButtonLocation.centerDocked,
            floatingActionButton: FloatingActionButton(
              onPressed: () => {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (constext) => const NewPinView()),
                )
              },
              child: Icon(
                Icons.add_location,
                color: ThemeData.dark().colorScheme.background,
              ),
            ),
          );
        });
  }

  FutureBuilder<List<PinboardPin>> pinsListFutureBuilder(
      PinsListViewModel model) {
    return FutureBuilder(
        future: model.recent_pins(currentTag),
        builder:
            (BuildContext context, AsyncSnapshot<List<PinboardPin>> snapshot) {
          if (!snapshot.hasData) {
            // while data is loading:
            // ignore: prefer_const_constructors
            return Center(
              child: const CircularProgressIndicator(),
            );
          } else if (snapshot.hasError) {
            return _getPinsListMessage(snapshot.error.toString());
          }
          // data loaded:
          var myRecentPosts = snapshot.data;

          // ignore: prefer_is_empty
          if (myRecentPosts?.length == 0) {
            return _getPinsListMessage(
                'No data found for your account. Add something and check back.');
          }

          return NotificationListener<ScrollEndNotification>(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 16),
              children: [
                if (myRecentPosts!.isEmpty) EmptyPage.showEmptyPinPage(),
                ...myRecentPosts.map((pin) {
                  TextEditingController descriptionController =
                      TextEditingController(text: pin.description);
                  return PinCard(
                      pin: pin,
                      model: model,
                      descriptionController: descriptionController,
                      onCurrentTagChanged: executeCurrentTagChange);
                })
              ],
            ),
            onNotification: (notification) {
              // 15 elements are about 920 pixels long
              // This varies slightly whether those pin elements have tags
              // so we err on the side of more page loads, which also improves ui.

              // NOTE the maximum recent pins the API will serve is 100...
              // When 10 pages load, there can be no more pages. At that point
              // a normal use case would be rather the search.
              if (notification.metrics.pixels > (numPagesLoaded * 700)) {
                model.addRecentPins(15, null);
                // ignore: avoid_print
                numPagesLoaded += 1;
                print("$numPagesLoaded pages loaded");
              }
              return true;
            },
          );
        });
  }

  void openFilterDialog(
      tagList, List<Tag> selectedTagList, PinsListViewModel model) async {
    await FilterListDialog.display<Tag>(
      context,
      listData: tagList,
      selectedListData: selectedTagList,
      themeData: FilterListThemeData.raw(
          choiceChipTheme: ChoiceChipThemeData.light(context),
          headerTheme: HeaderThemeData(
            backgroundColor: ThemeData.dark().colorScheme.primary,
          ),
          controlBarButtonTheme: ControlButtonBarThemeData.raw(
            controlButtonTheme: ControlButtonThemeData.dark(context),
            backgroundColor: ThemeData.dark().colorScheme.surface,
          ),
          borderRadius: 20,
          wrapAlignment: WrapAlignment.start,
          wrapCrossAxisAlignment: WrapCrossAlignment.start,
          wrapSpacing: 0.0,
          backgroundColor: ThemeData.dark().colorScheme.background),
      choiceChipLabel: (tag) => tag!.tag,
      enableOnlySingleSelection: true,
      validateSelectedItem: (list, val) => list!.contains(val),
      onItemSearch: (tag, query) {
        return tag.tag!.toLowerCase().contains(query.toLowerCase());
      },
      onApplyButtonClick: (tagList) {
        selectedTagList = List.from(tagList!);
        if (selectedTagList.isNotEmpty) {
          executeCurrentTagChange(selectedTagList.first);
        } else {
          executeCurrentTagRemove();
        }

        Navigator.of(context).pop();
      },
    );
  }

  void executeCurrentTagChange(Tag tagObject) {
    setState(() {
      appBarTitle = tagObject.tag;
    });
    mainViewModel.setCurrentTag(tagObject.tag);
    currentTag = tagObject;
    mainViewModel.emptyPinsHive();
  }

  void executeCurrentTagRemove() {
    setState(() {
      appBarTitle = "Recent Pins";
      currentTag = null;
    });
    mainViewModel.setCurrentTag(null);
    currentTag = null;
    mainViewModel.emptyPinsHive();
  }

  Drawer mainDrawer(PinsListViewModel model, BuildContext context) {
    return Drawer(
        child: ListView(padding: EdgeInsets.zero, children: [
      DrawerHeader(
          decoration:
              BoxDecoration(color: ThemeData.dark().colorScheme.background),
          child: const Text('Pinboard Pages')),
      // ListTile(

      ListTile(
        title: const Text("Choose a Tag"),
        onTap: () {
          Navigator.pop(context);
          openFilterDialog(model.tags, <Tag>[], model);
        },
      )
    ]));
  }

  // End of build method. Below are the other methods

  Widget _getPinsListMessage(String message) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Center(
            child: Text(
          message,
          textAlign: TextAlign.center,
          style:
              TextStyle(fontWeight: FontWeight.w900, color: Colors.grey[500]),
        )),
        ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text("Return to Login")),
      ],
    );
  }
}
