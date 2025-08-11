import 'package:erenapp/constants.dart';
import 'package:flutter/material.dart';

class OnbordingContent extends StatelessWidget {
  const OnbordingContent({
    super.key,
    required this.image,
    required this.title,
    required this.description,
    this.isTextOnTop = false,
  });

  final String image, title, description;
  final bool isTextOnTop;

  @override
  Widget build(BuildContext context) {
    final Widget textColumn = Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          title,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: defaultPadding),
        Text(
          description,
          textAlign: TextAlign.center,
        ),
      ],
    );

    final Widget imageWidget = Image.asset(image);

    return Column(
      children: [
        const Spacer(),
        isTextOnTop ? textColumn : imageWidget,
        const Spacer(),
        isTextOnTop ? imageWidget : textColumn,
        const Spacer(),
      ],
    );
  }
}