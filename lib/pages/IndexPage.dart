import 'package:flutter/material.dart';
import 'package:potato_leaf/pages/AboutPage.dart';

import 'HomePage.dart';

/// @author fangf
/// 路由页，用来控制页面之间的跳转

class IndexPage extends StatefulWidget {
  const IndexPage({Key? key}) : super(key: key);

  @override
  State<IndexPage> createState() => _IndexPageState();
}

class _IndexPageState extends State<IndexPage> {
  var currentIndex = 0;
  var pages = [const HomePage(), const AboutPage()];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    currentIndex = 0;
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      body: TweenAnimationBuilder(
        tween: Tween(begin: size.height, end: 0.0),
        curve: Curves.bounceOut,
        duration: const Duration(milliseconds: 1500),
        builder: (BuildContext context, double value, Widget? child) {
          return Transform.translate(
              offset: Offset(0, value),
              child: Container(
                child: child,
              ));
        },
        child: pages[currentIndex],
      ),
      bottomNavigationBar: (BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
              backgroundColor: Colors.green,
              icon: Icon(Icons.home),
              label: "首页"),
          BottomNavigationBarItem(
              backgroundColor: Colors.blue,
              icon: Icon(Icons.person),
              label: "关于")
        ],
        currentIndex: currentIndex,
        type: BottomNavigationBarType.fixed,
        onTap: (index) {
          if (currentIndex != index) {
            setState(() {
              currentIndex = index;
            });
          }
        },
      )),
    );
  }
}
