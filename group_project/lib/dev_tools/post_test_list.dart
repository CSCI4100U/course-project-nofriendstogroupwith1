/*

  This is only intended to make sure the Firestore database is working as intended.
  This will be removed later.

 */

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:group_project/models/post.dart';

import 'package:group_project/models/post_model.dart';

class PostTestList extends StatefulWidget {
  const PostTestList({Key? key}) : super(key: key);

  @override
  State<PostTestList> createState() => _PostTestListState();
}

class _PostTestListState extends State<PostTestList> {
  final PostModel _postModel = PostModel();

  Widget _buildListItem(Post post) {
    if (post.title==null) {
      print("No title!");
    }
    if (post.imageURL==null) {
      print("No imageURL!");
    }
    if (post.caption==null) {
      print("No caption!");
    }
    return Column(
      children: [
        Text(post.title!),
        Image.network(post.imageURL!),
        Text(post.caption!),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("[DEV] Test Post List"),
        actions: [
          IconButton(
              onPressed: (){
                setState(() {});
              },
              icon: const Icon(Icons.refresh)
          ),
        ],
      ),
      body: FutureBuilder(
        future: _postModel.getAllPostsList(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: snapshot.data!.map((post)
            => _buildListItem(post)
            ).toList(),
          );
        },
      ),
    );
  }
}
