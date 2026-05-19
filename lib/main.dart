import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'News',
      home: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.white,
          title: Text(
            'News',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
        ),
        body: RefreshIndicator(
          color: Colors.grey,
          backgroundColor: Colors.white,
          onRefresh: () async {
            Future.delayed(Duration(seconds: 1), () {
              setState(() {});
            });
          },
          child: FutureBuilder(
            future: fetchPost(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(
                  child: Text(
                    '${snapshot.error}',
                    style: TextStyle(fontSize: 18),
                  ),
                );
              } else if (snapshot.hasData) {
                final posts = snapshot.data!;
                return ListView.builder(
                  shrinkWrap: true,
                  itemCount: posts.length,
                  padding: EdgeInsets.all(8),
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      onTap: () {
                        launchUrl(
                          Uri.parse(posts[index].url),
                          mode: LaunchMode.externalApplication,
                        );
                      },
                      child: Container(
                        padding: EdgeInsets.all(8),
                        margin: EdgeInsets.only(top: 8),
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          spacing: 8,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(posts[index].urlToImage),
                            ),
                            Text(
                              posts[index].title,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              maxLines: 5,
                              posts[index].description,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  posts[index].author,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                Text(
                                  posts[index].publishedAt.substring(0, 10),
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              } else {
                return Text('No data found', style: TextStyle(fontSize: 18));
              }
            },
          ),
        ),
      ),
    );
  }
}

class Post {
  final String title;
  final String description;
  final String urlToImage;
  final String author;
  final String url;
  final String publishedAt;
  Post({
    required this.title,
    required this.description,
    required this.urlToImage,
    required this.author,
    required this.url,
    required this.publishedAt,
  });
  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      title: json['title'] ?? "",
      description: json['description'] ?? "",
      urlToImage: json['urlToImage'] ?? "",
      author: json['author'] ?? "",
      url: json['url'] ?? "",
      publishedAt: json['publishedAt'] ?? "",
    );
  }
}

Future<List<Post>> fetchPost() async {
  List<Post> posts = [];
  try {
    final response = await http.get(
      Uri.parse(
        'https://newsapi.org/v2/top-headlines?sources=techcrunch&apiKey=7d5748875f7349bb8a9423e613ac8792',
      ),
    );

    var data = jsonDecode(response.body);
    for (int i = 0; i < data['articles'].length; i++) {
      posts.add(Post.fromJson(data['articles'][i]));
    }
  } catch (e) {
    throw Exception('Failed to load post');
  }
  return posts;
}
