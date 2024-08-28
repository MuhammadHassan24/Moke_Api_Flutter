// API Integration With Dio

import 'dart:convert';

import 'package:apiproject/model/post_model.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

class ProfileView extends StatelessWidget {
  ProfileView({super.key});

  @override
  final dio = Dio();
  final url = "https://jsonplaceholder.typicode.com/posts";

  Future<List<PostModel>> fetchPosts() async {
    try {
      final response = await dio.get(url);

      if (response.statusCode == 200) {
        List<PostModel> posts = (response.data as List)
            .map((post) => PostModel.fromJson(post))
            .toList();
        return posts;
      } else {
        throw Exception('Failed to load posts');
      }
    } catch (e) {
      print(e);
      throw Exception('Error occurred while fetching posts');
    }
  }

  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<List<PostModel>>(
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
                          borderRadius: BorderRadius.all(Radius.circular(10))),
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
    );
  }
}
