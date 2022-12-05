import 'package:flutter/material.dart';
import 'package:group_project/models/post.dart';
import 'package:group_project/models/post_model.dart';
import 'package:group_project/models/saved.dart';
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

  Future<void> _showPost(Post post) async {
    await Navigator.pushNamed(context, "/postView", arguments: post);
    setState(() {

    });
  }

  Widget _buildPostTile(Post post) =>
    ListTile(
      title: Text(post.title??'NULL'),
      subtitle: Text(post.caption??'NULL'),
      leading: SizedBox(
          width: 60,
          height: 60,
          child: ClipRRect(
            borderRadius: const BorderRadius.all(Radius.circular(4.0)),
            child: Image.network(post.imageURL??"", height: 60),
          )
      ),
      onTap: () {
        _showPost(post);
      },
    );


  Widget _buildPostList(List<Post> _data) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: ListView.separated(
        itemBuilder: (context, index){
          return _buildPostTile(_data[index]);
        },
        separatorBuilder: (context, index){
          return const Divider();
        },
        itemCount: _data.length
      ),
    );
  }

  Future<List<Post>> _getAllSavedPosts() async {
    List<SavedPost> savedList = await _savedModel.getAllSaved(null);
    List<Post> result = [];
    for (SavedPost saved in savedList) {
      if (saved.documentID!=null) {
        Post post = await _postModel.getPostByReference(saved.documentID!);
        result.add(post);
      }
    }
    return result;
  }

  Future<List<Post>> _getAllHiddenPosts() async {
    List<SavedPost> savedList = await _savedModel.getAllHidden(null);
    print(savedList);
    List<Post> result = [];
    for (SavedPost saved in savedList) {
      if (saved.documentID!=null) {
        Post post = await _postModel.getPostByReference(saved.documentID!);
        result.add(post);
      }
    }
    return result;
  }

  List<Post> _savedPosts = [];
  List<Post> _hiddenPosts = [];

  Future<void> _initLists() async {
    _savedPosts = await _getAllSavedPosts();
    _hiddenPosts = await _getAllHiddenPosts();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _initLists(),
      builder: (context, snapshot) {
        if (snapshot.connectionState!=ConnectionState.done) {
          return const Center(child: CircularProgressIndicator(),);
        }
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
                children: [
                  _buildPostList(_savedPosts),
                  _buildPostList(_hiddenPosts),
                ],
              ),
            )
          ],
        );
      }
    );
  }
}
