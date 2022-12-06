import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:group_project/models/settings_model.dart';
import 'package:group_project/views/map_view.dart';
import 'package:group_project/views/post_data_view.dart';
import 'package:group_project/views/saved_post_view.dart';
import 'package:group_project/views/settings_view.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  static void setLanguage(BuildContext context, Locale newLocale) async {
    _HomePageState state =
    context.findAncestorStateOfType<_HomePageState>()!;
    state.setLanguage(newLocale);
  }

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final PageController _controller = PageController();

  final SettingsModel _settingsModel = SettingsModel();

  int _page = 0;

  void setLanguage(Locale newLocale) {
    FlutterI18n.refresh(context, newLocale).then((value) => setState((){}));
  }

  Future<void> _createPost() async {
    await Navigator.pushNamed(context, "/addPost");
  }

  void navigate(int page) {
    if (page>=0 && page<=4) {
      //Make sure the page exists
      _page = page;
      _controller.animateToPage(
        _page,
        curve: Curves.decelerate,
        duration: const Duration(milliseconds: 500),
      );
    }
  }

  @override
  void initState() {
    super.initState();

    _settingsModel.getStringSetting(SettingsModel.settingLanguage)
        .then((value) {
          value??="en-US";
          List<String> lang = value!.split("-");
          setLanguage(Locale(lang[0],lang[1]));
        });
  }

  @override
  Widget build(BuildContext context) {
    final List<String> pageNames = [
      "Map",
      "Post Stats",
      "", //Page 3 is empty (Just using button for add post)
      FlutterI18n.translate(context, "settings.page"),
      "Saved Posts",
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(pageNames[_page]),
        actions: [
          //TODO: Dev page access: remove along with dev page.
          IconButton(
              onPressed: () {
                Navigator.pushNamed(context, "/dev");
              },
              icon: const Icon(Icons.developer_mode)),
        ],
      ),
      body: PageView(
        physics: const NeverScrollableScrollPhysics(),
        scrollDirection: Axis.horizontal,
        controller: _controller,
        children: [
          const MapView(),
          const PostDataView(),
          Container(),
          const SettingsView(),
          const SavedPostView(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _page,
        type: BottomNavigationBarType.fixed,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.map_outlined),
            activeIcon: Icon(Icons.map),
            label: "Map",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart_outlined),
            activeIcon: Icon(Icons.bar_chart),
            label: "Post Stats",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add),
            label: "Add Post",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings_outlined),
            activeIcon: Icon(Icons.settings),
            label: FlutterI18n.translate(context, "settings.page"),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bookmarks_outlined),
            activeIcon: Icon(Icons.bookmarks),
            label: "Saved Posts",
          ),
        ],
        onTap: (value) {

            //Add post feature
            ///Important: Make sure this is equal to the index of the 'add' button.
            if (value==2) {
              //Temporarily jump to the empty "page 2" (setstate isn't sufficient to refresh the pageview)
                int temp = _page;
                _controller.jumpToPage(2);
                _createPost().then((value) => setState((){
                  _page = temp;
                  _controller.jumpToPage(temp);
                }));
            } else {
              //Navigate like normal
              setState((){
                navigate(value);
              });

            }
        },
      ),
    );
  }
}
