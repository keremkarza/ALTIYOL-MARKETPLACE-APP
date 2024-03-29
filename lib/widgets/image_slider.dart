import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dots_indicator/dots_indicator.dart';
import 'package:flutter/material.dart';

class ImageSlider extends StatefulWidget {
  @override
  _ImageSliderState createState() => _ImageSliderState();
}

class _ImageSliderState extends State<ImageSlider> {
  int _index = 0;
  int _dataLength = 1;

  @override
  void initState() {
    getSliderImageFromDb();
    super.initState();
  }

  Future getSliderImageFromDb() async {
    var _fireStore = FirebaseFirestore.instance;
    QuerySnapshot snapshot = await _fireStore.collection('sliders').get();
    if (mounted) {
      setState(() {
        _dataLength = snapshot.docs.length;
      });
    }
    return snapshot.docs;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Column(
        children: [
          if (_dataLength != 0)
            FutureBuilder(
              future: getSliderImageFromDb(),
              builder: (_, snapShot) {
                return snapShot.data == null
                    ? Center(
                        child: CircularProgressIndicator(),
                      )
                    : Padding(
                        // sağdan veya soldan verilirse farklı bir tasarım olabilir?
                        padding: const EdgeInsets.all(20),
                        child: CarouselSlider.builder(
                          itemCount: snapShot.data.length,
                          itemBuilder: (context, int index, int index2) {
                            DocumentSnapshot sliderImage = snapShot.data[index];
                            Map getImage = sliderImage.data();
                            return ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: SizedBox(
                                  width: MediaQuery.of(context).size.width,
                                  child: Image.network(
                                    getImage['image'],
                                    fit: BoxFit.fill,
                                  )),
                            );
                          },
                          options: CarouselOptions(
                              viewportFraction: 1,
                              initialPage: 0,
                              autoPlay: true,
                              height:
                                  MediaQuery.of(context).size.height * (3 / 10),
                              onPageChanged:
                                  (int i, carouselPageChangedReason) {
                                setState(() {
                                  _index = i;
                                });
                              }),
                        ),
                      );
              },
            ),
          if (_dataLength != 0)
            Visibility(
              visible: false,
              child: DotsIndicator(
                dotsCount: _dataLength,
                position: _index.toDouble(),
                decorator: DotsDecorator(
                    size: const Size.square(5.0),
                    activeSize: const Size(18.0, 5.0),
                    activeShape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5.0)),
                    activeColor: Theme.of(context).primaryColor),
              ),
            )
        ],
      ),
    );
  }
}
