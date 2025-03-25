import 'package:flutter/material.dart';
import 'package:mseva_punjab/utils/web_view_body_load.dart';
//import 'package:mseva/utils/web_view_body_load.dart';


class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return const SafeArea(
      child: WebViewBodyLoad(
        pageTitle: 'mSeva',
        pageUrl: 'https://mseva.lgpunjab.gov.in/citizen/language-selection',
        headerFooterRequired: false,
      ),
    );
  }
}
