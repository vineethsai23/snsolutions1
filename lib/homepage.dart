import 'dart:math';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:timeago/timeago.dart' as timeago;

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<dynamic> posts = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchPosts();
  }

  Future<void> fetchPosts() async {
    const String url = 'https://api.hive.blog/';
    const Map<String, String> headers = {
      'accept': 'application/json, text/plain, */*',
      'content-type': 'application/json',
    };
    const String body =
        '{"id":1,"jsonrpc":"2.0","method":"bridge.get_ranked_posts","params":{"sort":"trending","tag":"","observer":"hive.blog"}}';

    try {
      final response =
          await http.post(Uri.parse(url), headers: headers, body: body);
      print('Response: ${response.body}');
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);

        setState(() {
          posts = data['result'];
          isLoading = false;
        });
      } else {
        print('Failed to fetch data: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 20),
                    child: Row(
                      children: [
                        Text(
                          "All Posts",
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                        )
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 15,
                  ),
                  Expanded(
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: posts.length,
                      itemBuilder: (context, index) {
                        final post = posts[index];

                        final author = post['author'] ?? '';
                        final authorRole = post['author_role'] ?? '';
                        final pay = post['payout'] ?? '';
                        final community = post['community_title'] ?? '';
                        final title = post['title'] ?? '';
                        final description = (post['body'] as String?)
                                ?.substring(
                                    0, min(post['body']!.length, 1000)) ??
                            '';

                        final createdAt = DateTime.parse(post['created']);
                        final relativeTime = timeago.format(createdAt);
                        final likes =
                            (post['active_votes'] as List<dynamic>?)?.length ??
                                0;
                        final images = post['json_metadata'] != null &&
                                post['json_metadata']['image'] != null &&
                                post['json_metadata']['image'].isNotEmpty
                            ? post['json_metadata']['image'][0]
                            : '';

                        final comments = post['children'] ?? 0;

                        return Card(
                          child: Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: Column(
                              children: [
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Container(
                                      height: 30,
                                      width: 30,
                                      decoration: BoxDecoration(
                                        image: DecorationImage(
                                          image: NetworkImage(images),
                                          fit: BoxFit.cover,
                                        ),
                                        borderRadius:
                                            BorderRadius.circular(10.0),
                                      ),
                                    ),
                                    Text('@$author,',
                                        style: const TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold)),
                                    Text('$authorRole in ',
                                        style: const TextStyle(
                                          color: Colors.grey,
                                          fontSize: 10,
                                        )),
                                    Text(community,
                                        style: const TextStyle(
                                            fontSize: 13, color: Colors.grey)),
                                    Text(relativeTime,
                                        style: const TextStyle(
                                            color: Colors.grey, fontSize: 13)),
                                  ],
                                ),
                                const SizedBox(height: 5),
                                Text(title,
                                    style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold)),
                                const SizedBox(height: 5),
                                Text(description,
                                    maxLines: 3,
                                    overflow: TextOverflow.ellipsis),
                                const SizedBox(height: 5),
                                Row(
                                  children: [
                                    Text('\$$pay'),
                                    const SizedBox(width: 5),
                                    Icon(Icons.thumb_up,
                                        size: 16, color: Colors.grey[700]),
                                    const SizedBox(width: 5),
                                    Text('$likes'),
                                    const SizedBox(width: 20),
                                    Icon(Icons.comment,
                                        size: 16, color: Colors.grey[700]),
                                    const SizedBox(width: 5),
                                    Text('$comments'),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
