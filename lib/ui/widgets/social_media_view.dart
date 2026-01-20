import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../ui.dart';

class SocialMediaView extends StatelessWidget {
  const SocialMediaView({super.key});

  @override
  Widget build(BuildContext context) {
    List<IconData> socialIcons = [
      AppIcons.linkedIn,
      AppIcons.xTwitter,
      AppIcons.gitHub,
    ];
    List<String> urls = [
      "https://linkedin.com/in/georgesbyona",
      "https://x.com/namidrc",
      "https://github.com/namidrc",
    ];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: List.generate(
        socialIcons.length,
        (index) => IconButton(
          onPressed: () => _launchUrl(urls[index]),
          splashColor: Colors.transparent,
          focusColor: Colors.transparent,
          hoverColor: Colors.transparent,
          icon: Icon(socialIcons[index]),
        ),
      ),
    );
  }

  Future<void> _launchUrl(String url) async {
    if (!await launchUrl(Uri.parse(url))) {
      debugPrint('Could not launch $url');
    }
  }
}
