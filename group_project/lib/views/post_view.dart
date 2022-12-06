import 'package:flutter/material.dart';
import 'package:group_project/models/db_utils.dart';
import 'package:group_project/models/post_model.dart';
import 'package:group_project/models/post.dart';
import 'package:group_project/models/saved_model.dart';
import 'package:geocoding/geocoding.dart';
import 'dart:async';

class PostView extends StatefulWidget {
  const PostView({Key? key}) : super(key: key);

  @override
  State<PostView> createState() => _PostViewState();
}

class _PostViewState extends State<PostView> {
  final PostModel _postModel = PostModel();
  final SavedModel _savedModel = SavedModel();
  //bool isArgumentLoaded = false;

  Widget _buildCaptionBox(String? caption) {
    if (caption == null) {
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
    late Widget image;

    print("Getting image");
    image = Image.network(post.imageURL!,
        errorBuilder: ((context, error, stackTrace) =>
            const Text("Network Error: Image not found.")));
    print("image done");

    return ListView(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: ClipRRect(
            borderRadius: const BorderRadius.all(Radius.circular(16.0)),
            child: image,
          ),
        ),
        FutureBuilder(
            future: placemarkFromCoordinates(
                post.location!.latitude, post.location!.longitude),
            builder: ((context, snapshot) {
              if (!snapshot.hasData) {
                return const LinearProgressIndicator();
              }
              return Container(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8),
                  child: RichText(
                      text: TextSpan(
                          text: snapshot.data![0].street! +
                              ", " +
                              snapshot.data![0].locality! +
                              " " +
                              snapshot.data![0].administrativeArea!,
                          style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold))),
                ),
              );
            })),
        _buildCaptionBox(post.caption ?? "[Missing Caption]"),
      ],
    );
  }

  Future<Map<String, dynamic>> _getPostInfo(Post? argumentPost) async {
    late Post post;
    if (argumentPost == null) {
      List<Post> allposts = await _postModel.getAllPostsList();
      post = allposts[0];
    } else {
      post = argumentPost;
    }

    bool deleted = post.reference == null;
    bool? saved;
    bool? hidden;
    if (!deleted) {
      saved = await _savedModel.isPostSaved(null, post.reference!.id);
      hidden = await _savedModel.isPostHidden(null, post.reference!.id);
    }
    return {
      'post': post,
      'saved': saved ?? true,
      'hidden': hidden ?? true,
      'deleted': deleted,
    };
  }

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments as Post?;
    Post? argumentPost = args;

    return FutureBuilder(
      future: _getPostInfo(argumentPost),
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

        if (snapshot.data!.isEmpty) {
          return Scaffold(
            appBar: AppBar(
              title: const Text("No posts found"),
            ),
          );
        }

        //Otherwise, if the post has loaded:

        //Grab the post data
        Post post = snapshot.data!['post'];
        bool deleted = snapshot.data!['deleted'];
        bool hidden = snapshot.data!['hidden'];
        bool saved = snapshot.data!['saved'];

        IconData hideIcon = Icons.visibility_off_outlined;
        if (hidden) {
          hideIcon = Icons.visibility_off;
        }

        IconData saveIcon = Icons.bookmark_border;
        if (saved) {
          saveIcon = Icons.bookmark;
        }

        List<Widget> postActions = [];
        if (!hidden) {
          postActions.add(
            IconButton(
                onPressed: () {
                  setState(() {
                    if (saved) {
                      if (deleted) {
                        _savedModel
                            .unsavePost(null, post)
                            .then((value) => Navigator.of(context).pop());
                      } else {
                        _savedModel.unsavePost(null, post);
                      }
                    } else {
                      _savedModel.savePost(null, post);
                    }
                  });
                },
                tooltip: "Save Post",
                icon: Icon(saveIcon)),
          );
        }

        postActions.add(IconButton(
          onPressed: () {
            setState(() {
              if (hidden) {
                if (deleted) {
                  _savedModel
                      .unsavePost(null, post)
                      .then((value) => Navigator.of(context).pop());
                } else {
                  _savedModel.unsavePost(null, post);
                }
              } else {
                _savedModel.hidePost(null, post);
              }
            });
          },
          tooltip: "Hide Post",
          icon: Icon(hideIcon),
        ));

        return Scaffold(
          appBar: AppBar(
            title: Text(post.title ?? "[Missing Title]"),
            actions: postActions,
          ),
          body: _buildPost(post),
        );
      },
    );
  }
}
