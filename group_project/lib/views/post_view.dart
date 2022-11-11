import 'package:flutter/material.dart';

import 'package:group_project/models/post_model.dart';
import 'package:group_project/models/post.dart';

class PostView extends StatefulWidget {
  const PostView({Key? key}) : super(key: key);

  @override
  State<PostView> createState() => _PostViewState();
}

class _PostViewState extends State<PostView> {
  final PostModel _postModel = PostModel();

  Widget _buildCaptionBox(String? caption) {
    if (caption==null) {
      return Container();
    }
    return Container(
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(16.0)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Text(caption),
      ),
    );
  }

  Widget _buildPost(Post post) {
    return ListView(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: ClipRRect(
            borderRadius: const BorderRadius.all(Radius.circular(16.0)),
            child: Image.network(post.imageURL!),
          ),
        ),
        _buildCaptionBox(post.caption!),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: _postModel.getTestPost(),
        builder: (context, snapshot) {
          //If the post hasn't loaded yet...
          if (!snapshot.hasData) {
            return Scaffold(
              appBar: AppBar(),
              body: const Center(
                child: CircularProgressIndicator(),
              ),
            );
          }

          return Scaffold(
            appBar: AppBar(
              title: Text(snapshot.data!.title!),
              actions: [
                IconButton(
                    onPressed: (){},
                    icon: const Icon(Icons.bookmark_add_outlined)
                ),
                PopupMenuButton(
                    itemBuilder: (context) {
                      List<String> menuItems = [
                        "Report",
                        "Hide",
                      ];
                      return menuItems.map(
                          (menuItem) => PopupMenuItem(
                            value: menuItem,
                            child: Text(menuItem),
                          )
                      ).toList();
                    }
                ),
              ],
            ),
            body: _buildPost(snapshot.data!),
          );
        },
    );
  }
}
