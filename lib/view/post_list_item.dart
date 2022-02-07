part of './post_page.dart';

class PostListItem extends StatelessWidget {
  const PostListItem({Key? key, required this.post}) : super(key: key);
  final Post post;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Text(
        '${post.id}',
        style: const TextTheme().caption,
      ),
      title: Text(post.title),
      isThreeLine: true,
      subtitle: Text(
        post.body,
        style: const TextTheme().subtitle1,
      ),
      dense: true,
    );
  }
}
