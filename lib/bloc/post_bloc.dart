import 'dart:convert';
import 'package:bloc/bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:equatable/equatable.dart';
import 'package:http/http.dart' as http;
import 'package:stream_transform/stream_transform.dart';

import '../model/post.dart';

part 'post_event.dart';
part 'post_state.dart';

const _postLimit = 20;

const throttleDuration = Duration(microseconds: 100);

EventTransformer<E> throttleDroppable<E>(Duration duration) {
  return (events, mapper) {
    return droppable<E>().call(events.throttle(duration), mapper);
  };
}

class PostBloc extends Bloc<PostEvent, PostState> {
  PostBloc({required this.httpClient}) : super(const PostState()) {
    on<PostFetched>(_onPostFetched,
        transformer: throttleDroppable(throttleDuration));
    on<PostReset>(_onPostReset);
  }

  final http.Client httpClient;

  Future<void> _onPostFetched(
      PostFetched event, Emitter<PostState> emit) async {
    int len = state.posts.length;
    print('init ::: $len');

    await validatePost(event, emit);
  }

  Future<void> _onPostReset(PostReset event, Emitter<PostState> emit) async {
    emit(state.copyWith(
        status: PostStatus.initial, posts: [], hasReachedMax: false));

    await Future.delayed(const Duration(seconds: 2));

    await validatePost(event, emit);
  }

  Future<void> validatePost(event, emit) async {
    if (state.hasReachedMax) return;

    try {
      if (state.status == PostStatus.initial) {
        final posts = await _fetchPosts();

        return emit(state.copyWith(
            status: PostStatus.success, posts: posts, hasReachedMax: false));
      }

      final posts = await _fetchPosts(state.posts.length);
      emit(posts.isEmpty
          ? state.copyWith(hasReachedMax: true)
          : state.copyWith(
              status: PostStatus.success,
              posts: List.of(state.posts)..addAll(posts),
              hasReachedMax: false));
    } catch (error) {
      print('fetch error : $error');
      emit(state.copyWith(status: PostStatus.failure));
    }
  }

  Future<List<Post>> _fetchPosts([int startIndex = 0]) async {
    final response = await httpClient.get(Uri.https(
        'jsonplaceholder.typicode.com',
        '/posts',
        <String, String>{'_start': '$startIndex', '_limit': '$_postLimit'}));

    if (response.statusCode == 200) {
      final body = json.decode(response.body) as List;

      return body.map((dynamic json) {
        return Post(
            id: json['id'] as int,
            title: json['title'] as String,
            body: json['body'] as String);
      }).toList();
    }

    throw Exception('error fetching data');
  }
}
