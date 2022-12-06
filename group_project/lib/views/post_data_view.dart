import 'package:flutter/material.dart';
import 'package:group_project/models/post_model.dart';
import "dart:async";

class PostDataView extends StatefulWidget {
  const PostDataView({Key? key}) : super(key: key);

  @override
  State<PostDataView> createState() => _PostDataViewState();
}

class _PostsOnDay {
  late int daysAgo;
  late int posts;
  _PostsOnDay(int day, int n) {
    daysAgo = day;
    posts = n;
  }
}

class _PostDataViewState extends State<PostDataView> {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: PostModel().getAllPostsList(),
        builder: ((context, snapshot) {
          if (!snapshot.hasData) {
            //Loading screen
            return Container(
                alignment: Alignment.center,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: const [
                    CircularProgressIndicator(),
                    Text("Loading Posts")
                  ],
                ));
          }
          //after loaded

          //--------Build our data----------
          final _currentTime = DateTime.now().millisecondsSinceEpoch;
          const _msperday = 86400000;
          Map<int, int> _postsPerDay = {};
          snapshot.data!.forEach(
            (element) {
              //For each post, figure out how many days ago it was posted and increment the appropriate key in the map
              int daysAgo =
                  ((_currentTime - element.dateTime!) / _msperday).floor();
              _postsPerDay[daysAgo] = (_postsPerDay[daysAgo] ?? 0) + 1;
            },
          );
          List<_PostsOnDay> data = [];
          _postsPerDay.forEach(
            (key, value) {
              //for each, turn into a list of _PostsOnDay for easier reading
              data.add(_PostsOnDay(key, value));
            },
          );
          data.sort((a, b) => a.daysAgo.compareTo(b.daysAgo));

          return SingleChildScrollView(
            child: DataTable(
              columns: const [
                DataColumn(label: Text("Days Ago")),
                DataColumn(label: Text("Number of Posts"))
              ],
              rows: [
                for (int i = 0; i < data.length; i++)
                  DataRow(cells: [
                    DataCell(Text(data[i].daysAgo.toString())),
                    DataCell(Text(data[i].posts.toString()))
                  ])
              ],
            ),
          );
        }));
  }
}
