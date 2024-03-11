import 'package:flutter/material.dart';

class FullScreenImage extends StatefulWidget {
  final String imageUrl;
  const FullScreenImage({Key? key, required this.imageUrl}) : super(key: key);

  @override
  _FullScreenImageState createState() => _FullScreenImageState(this.imageUrl);
}

class _FullScreenImageState extends State<FullScreenImage> {
  final String imageUrl;
  _FullScreenImageState(this.imageUrl);
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    print(widget.imageUrl);
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor:
            Theme.of(context).colorScheme.inversePrimary.withOpacity(0.5),
      ),
      body: Center(
        child: Image.network(widget.imageUrl),
      ),
    );
  }
}
