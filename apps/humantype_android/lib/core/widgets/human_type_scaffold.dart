import 'package:flutter/material.dart';

import '../theme.dart';

class HumanTypeScaffold extends StatelessWidget {
  const HumanTypeScaffold({
    super.key,
    required this.body,
    this.title,
    this.actions,
    this.padding,
    this.showBack = false,
    this.enableScroll = true,
  });

  final String? title;
  final Widget body;
  final List<Widget>? actions;
  final EdgeInsetsGeometry? padding;
  final bool showBack;
  final bool enableScroll;

  @override
  Widget build(BuildContext context) {
    final content = Padding(
      padding: padding ?? const EdgeInsets.all(HumanTypeSpacing.lg),
      child: body,
    );

    return Scaffold(
      appBar: AppBar(
        title:
            title == null ? null : Text(title!, style: HumanTypeText.heading2),
        centerTitle: false,
        automaticallyImplyLeading: showBack,
        actions: actions,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [HumanTypeColors.bgPrimary, HumanTypeColors.bgSecondary],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: enableScroll ? SingleChildScrollView(child: content) : content,
        ),
      ),
    );
  }
}
