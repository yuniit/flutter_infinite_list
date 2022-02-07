import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;

import '../bloc/post_bloc.dart';
import '../model/post.dart';

part './post_list.dart';
part './bottom_loader.dart';
part 'post_list_item.dart';

class PostPage extends StatelessWidget {
  const PostPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Infinite List')),
      body: BlocProvider(
        create: (BuildContext context) =>
            PostBloc(httpClient: http.Client())..add(PostFetched()),
        child: Container(
          padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
          child: Column(
            children: const [
              ChildA(),
              SizedBox(
                height: 8,
              ),
              Expanded(child: PostList())
            ],
          ),
        ),
      ),
    );
  }
}

class ChildA extends StatelessWidget {
  const ChildA({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        child: ElevatedButton.icon(
      onPressed: () => context.read<PostBloc>().add(PostReset()),
      icon: const Icon(Icons.restart_alt),
      label: const Text('Reset'),
      style: ElevatedButton.styleFrom(
        minimumSize: const Size.fromHeight(50),
        primary: Colors.amber[700],
      ),
    ));
  }
}
