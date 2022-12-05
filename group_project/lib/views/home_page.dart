import 'package:flutter/material.dart';
import 'package:group_project/views/map_view.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final PageController _controller = PageController();

  int _page = 0;

  final List<String> pageNames = [
    "Map",
    "Post Stats",
    "", //Page 3 is empty (Just using button for add post)
    "Settings",
    "Saved Posts",
  ];


  Future<void> _createPost() async {
    await Navigator.pushNamed(context, "/addPost");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(pageNames[_page]),
        actions: [
          //TODO: Dev page access: remove along with dev page.
          IconButton(
              onPressed: (){
                Navigator.pushNamed(context, "/dev");
              },
              icon: const Icon(Icons.developer_mode)
          ),
        ],
      ),
      body: PageView(
        physics: const ScrollPhysics(),
        scrollDirection: Axis.horizontal,
        controller: _controller,
        children: [
          const MapView(),
          Center(child: Text("Post Data Here")),
          Container(),
          Center(child: Text("Settings Here")),
          Center(child: Text("Saved Posts Here")),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
          currentIndex: _page,
          type: BottomNavigationBarType.fixed,
          items: const [
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
              label: "Settings",
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
              _createPost();
            } else {
              //Navigate like normal
              setState((){
                _page = value;
              });
              _controller.animateToPage(
                _page,
                curve: Curves.decelerate,
                duration: const Duration(milliseconds: 250),
              );
            }
        },
      ),
    );
  }
}
