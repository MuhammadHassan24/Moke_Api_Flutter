// API Integration With Http

import 'dart:convert';
import 'package:apiproject/model/post_model.dart';
import 'package:apiproject/view/profile_view.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  Future<List<PostModel>>? _futurePosts; // Declare a Future to hold the result
  bool _hasFetched = false;
  void _fetchPosts() {
    if (!_hasFetched) {
      setState(() {
        _futurePosts = fetchPosts();
        _hasFetched = true; // Set flag to true to prevent further calls
      });
    }
  }

  final url = "https://jsonplaceholder.typicode.com/posts";

  Future<List<PostModel>> fetchPosts() async {
    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final responseBody = jsonDecode(response.body);
        List<PostModel> postList = [];

        if (responseBody is List) {
          // Handle the case where the response is a list of posts
          for (var item in responseBody) {
            PostModel post = PostModel.fromJson(item);
            postList.add(post);
          }
        } else if (responseBody is Map<String, dynamic>) {
          // Handle the case where the response is a single post
          PostModel post = PostModel.fromJson(responseBody);
          postList.add(post);
        } else {
          throw Exception("Unexpected JSON format");
        }

        return postList;
      } else {
        throw Exception("Error: ${response.statusCode}");
      }
    } catch (e) {
      print("Failed to fetch posts: $e");
      rethrow; // Re-throw the error so that FutureBuilder can handle it
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
              onPressed: () {
                Navigator.of(context).push(createRoute());
              },
              icon: Icon(Icons.arrow_forward))
        ],
      ),
      body: _futurePosts == null
          ? Center(
              child: Text("Pressed Button"),
            )
          : FutureBuilder<List<PostModel>>(
              future: fetchPosts(),
              builder: (con, sna) {
                if (sna.hasError) {
                  return const Center(child: Text("Error"));
                } else if (sna.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (!sna.hasData || sna.data!.isEmpty) {
                  return const Center(
                    child: Text("data Is Not Load"),
                  );
                } else {
                  List<PostModel> posts = sna.data!;
                  return ListView.separated(
                      separatorBuilder: (cont, index) {
                        return SizedBox(
                          height: 10,
                        );
                      },
                      itemCount: posts.length,
                      itemBuilder: (con, ind) {
                        final p = posts[ind];
                        return Container(
                          height: 150,
                          width: 200,
                          decoration: BoxDecoration(
                              color: Colors.purple[300],
                              borderRadius:
                                  BorderRadius.all(Radius.circular(10))),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                FittedBox(
                                  child: Text(p.id.toString()),
                                ),
                                FittedBox(
                                  child: Text(p.title.toString()),
                                ),
                                FittedBox(
                                  child: Text(p.body.toString()),
                                ),
                              ],
                            ),
                          ),
                        );
                      });
                }
              }),
      floatingActionButton: FloatingActionButton(
        onPressed: _fetchPosts,
        child: Text("Pressed"),
      ),
    );
  }
}

Route createRoute() {
  return PageRouteBuilder(
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      var begin = 0.0;
      var end = 1.0;
      var curve = Curves.easeInOutBack;

      var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

      return FadeTransition(
        opacity: animation.drive(tween),
        child: child,
      );
    },
    pageBuilder: (context, animation, secondaryAnimation) => ProfileView(),
  );
}
