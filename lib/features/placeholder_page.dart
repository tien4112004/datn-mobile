import 'package:auto_route/auto_route.dart';
import 'package:datn_mobile/core/router/router.gr.dart';
import 'package:flutter/material.dart';

@RoutePage()
class PlaceholderPage extends StatelessWidget {
  const PlaceholderPage({super.key, this.title = 'Home Page'});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(child: Text(title)),
    );
  }
}

@RoutePage()
class PlaceholderPageSchedule extends StatelessWidget {
  const PlaceholderPageSchedule({super.key, this.title = 'Schedule Page'});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(child: Text(title)),
    );
  }
}

@RoutePage()
class PlaceholderPageAnnounce extends StatelessWidget {
  const PlaceholderPageAnnounce({super.key, this.title = 'Sign In Page'});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: OutlinedButton(
          onPressed: () {
            context.router.push(const SignInRoute());
          },
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 12),
            side: BorderSide(color: Theme.of(context).colorScheme.primary),
          ),
          child: const Text("Go to Sign In"),
        ),
      ),
    );
  }
}
