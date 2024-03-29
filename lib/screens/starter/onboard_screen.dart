import 'package:dots_indicator/dots_indicator.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';

import '../../constants.dart';

class OnBoardScreen extends StatefulWidget {
  static const String id = 'onboard-screen';
  @override
  _OnBoardScreenState createState() => _OnBoardScreenState();
}

final _controller = PageController(
  initialPage: 0,
);
int _currentPage = 0;
List<Widget> _pages = [
  Column(
    children: [
      Expanded(child: Image.asset("images/enteraddress.png")),
      Text(
        "Teslimat bölgeni seç",
        style: kPageViewTextStyle,
        textAlign: TextAlign.center,
      ),
    ],
  ),
  Column(
    children: [
      Expanded(child: Image.asset("images/orderfood.png")),
      Text(
        "SEVDİĞİN DÜKKANLARDAN SİPARİŞ VER",
        style: kPageViewTextStyle,
        textAlign: TextAlign.center,
      ),
    ],
  ),
  Column(
    children: [
      Expanded(child: Image.asset("images/deliverfood.png")),
      Text(
        "KAPINA HIZLI TESLİMAT",
        style: kPageViewTextStyle,
        textAlign: TextAlign.center,
      ),
    ],
  ),
];

class _OnBoardScreenState extends State<OnBoardScreen> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: PageView(
            controller: _controller,
            children: _pages,
            onPageChanged: (index) {
              setState(() {
                _currentPage = index;
              });
            },
          ),
        ),
        SizedBox(height: 20),
        DotsIndicator(
          dotsCount: _pages.length,
          position: _currentPage.toDouble(),
          decorator: DotsDecorator(
            size: const Size.square(9.0),
            activeSize: const Size(18.0, 9.0),
            activeShape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(5.0)),
            activeColor: Theme.of(context).primaryColor,
          ),
        ),
        SizedBox(height: 20),
      ],
    );
  }
}
