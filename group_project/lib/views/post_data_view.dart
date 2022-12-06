import 'package:flutter/material.dart';
import 'package:group_project/models/post_model.dart';
import 'package:community_charts_flutter/community_charts_flutter.dart'
    as charts;

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

          //generate data for the chart, last 7 days will 0 filled in
          const _daysToDraw = 7;
          List<_PostsOnDay> chartData = [];
          for (int i = 0; i < _daysToDraw; i++) {
            chartData.add(_PostsOnDay(i, _postsPerDay[i] ?? 0));
          }
          charts.Series<_PostsOnDay, int> charSeries = charts.Series(
              data: chartData,
              id: "Posts Per Day",
              domainFn: (post, index) {
                return (post as _PostsOnDay).daysAgo;
              },
              measureFn: (datum, index) => (datum as _PostsOnDay).posts,
              displayName: "Number of Posts in last 7 Days");

          //--------------Draw--------------
          return SingleChildScrollView(
              child: Column(
            children: [
              Container(
                alignment: Alignment.topCenter,
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 10),
                  child: Text("Posts over the last 7 days"),
                ),
              ),
              Container(
                height: 300,
                child: charts.LineChart(
                  [charSeries],
                ),
              ),
              DataTable(
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
            ],
          ));
        }));
  }
}
