import 'package:flutter/material.dart';
import 'package:group_project/models/post_model.dart';
import 'package:group_project/models/saved_model.dart';

class SavedPostView extends StatefulWidget {
  const SavedPostView({Key? key}) : super(key: key);

  @override
  State<SavedPostView> createState() => _SavedPostViewState();
}

class _SavedPostViewState extends State<SavedPostView> with SingleTickerProviderStateMixin {
  static const List<Tab> _tabs = <Tab>[
    Tab(text: 'Saved'),
    Tab(text: 'Hidden'),
  ];

  late final TabController _tabController;

  final SavedModel _savedModel = SavedModel();
  final PostModel _postModel = PostModel();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    super.dispose();
    _tabController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TabBar(
          labelColor: Colors.black,
          controller: _tabController,
          tabs: _tabs
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: const [
              Center(child: Text("Page 1"),),
              Center(child: Text("Page 2"),),
            ],
          ),
        )
      ],
    );
  }
}
