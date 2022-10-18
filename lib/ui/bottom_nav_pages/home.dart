import 'package:carousel_slider/carousel_slider.dart';
import 'package:e_commerce_app/const/app_colors.dart';
import 'package:e_commerce_app/ui/all_product_screen.dart';
import 'package:e_commerce_app/ui/detail_screen.dart';
import 'package:e_commerce_app/ui/search_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dots_indicator/dots_indicator.dart';
import 'package:intl/intl.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final _firestoreInstance = FirebaseFirestore.instance;
  final List<String> _carouselImages = [];
  var _dotPosition = 0;
  final List _listProducts = [];
  final List<String> _listCategories = [];
  final oCcy =
      NumberFormat.currency(locale: 'vi-VN', symbol: 'VND', decimalDigits: 0);

  getDataSlider() async {
    CollectionReference reference =
        _firestoreInstance.collection('imageSlider');
    reference.snapshots().listen((querySnapshot) {
      for (var change in querySnapshot.docChanges) {
        _carouselImages.add(
          change.doc["imgUrl"],
        );
      }
    });
  }

  getDataCategories() async {
    CollectionReference reference =
        _firestoreInstance.collection('dataCategories');
    reference.snapshots().listen((querySnapshot) {
      for (var change in querySnapshot.docChanges) {
        _listCategories.add(
          change.doc["productType"],
        );
      }
    });
  }

  getDataProducts() async {
    CollectionReference reference =
        _firestoreInstance.collection('dataProducts');
    reference.snapshots().listen((querySnapshot) {
      for (var change in querySnapshot.docChanges) {
        _listProducts.add({
          "productName": change.doc['productName'],
          "productImage": change.doc['productImage'],
          "productDescription": change.doc['productDescription'],
          "productQuantities": change.doc['productQuantities'],
          "productNumLikes": change.doc['productNumLikes'],
          "productPrice": change.doc['productPrice'],
          "productType": change.doc['productType'],
        });
      }
    });
  }

  @override
  void initState() {
    getDataSlider();
    getDataCategories();
    getDataProducts();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 20, right: 20),
                child: TextFormField(
                  readOnly: true,
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.search),
                    fillColor: Colors.white,
                    focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(20)),
                        borderSide: BorderSide(color: Colors.blue)),
                    enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(20)),
                        borderSide: BorderSide(color: Colors.grey)),
                    hintText: "Search products here!!!",
                    hintStyle: TextStyle(fontSize: 15),
                  ),
                  onTap: () => {
                    Navigator.push(context,
                        CupertinoPageRoute(builder: (_) => const SearchScreen())),
                  },
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              AspectRatio(
                aspectRatio: 3.5,
                child: CarouselSlider(
                  items: _carouselImages
                      .map((item) => Padding(
                            padding: const EdgeInsets.only(left: 3, right: 3),
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius:
                                    const BorderRadius.all(Radius.circular(10)),
                                image: DecorationImage(
                                    image: NetworkImage(item), fit: BoxFit.fill),
                              ),
                            ),
                          ))
                      .toList(),
                  options: CarouselOptions(
                      autoPlay: true,
                      enlargeCenterPage: true,
                      viewportFraction: 1,
                      enlargeStrategy: CenterPageEnlargeStrategy.height,
                      onPageChanged: (val, carouselPageChangedReason) {
                        setState(() {
                          _dotPosition = val;
                        });
                      }),
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              DotsIndicator(
                dotsCount: _carouselImages.isEmpty ? 1 : _carouselImages.length,
                position: _dotPosition.toDouble(),
                decorator: DotsDecorator(
                  activeColor: AppColors.deepOrange,
                  color: AppColors.deepOrange.withOpacity(0.5),
                  spacing: const EdgeInsets.all(2),
                  activeSize: const Size(10, 10),
                  size: const Size(9, 9),
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              Padding(
                padding: const EdgeInsets.only(left: 8, right: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Categories',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    InkWell(
                      child: const Text('View all'),
                      onTap: () {
                        print('Click View all Categories');
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(
                height: 8,
              ),
              SizedBox(
                height: 50,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  separatorBuilder: (BuildContext context, int index) =>
                      const Divider(),
                  itemCount: _listCategories.length,
                  itemBuilder: (BuildContext context, int index) {
                    return Container(
                      margin: const EdgeInsets.only(left: 10, right: 10),
                      width: 100,
                      height: 50,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10.0),
                        color: Colors.deepOrange,
                        boxShadow: const [
                          BoxShadow(
                            blurStyle: BlurStyle.solid,
                            color: Colors.orangeAccent,
                            blurRadius: 8.0,
                            spreadRadius: 3.0,
                            offset: Offset(2, 3), // changes position of shadow
                          ),
                        ],
                      ),
                      child: InkWell(
                        onTap: () {
                          print("Click categories item");
                          print(_listCategories[index]);
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) =>
                                      AllProductScreen(_listCategories[index])));
                        },
                        child: Text(
                          _listCategories[index].toUpperCase(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              Padding(
                padding: const EdgeInsets.only(left: 8, right: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Products',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    InkWell(
                      child: const Text('View all'),
                      onTap: () {
                        print('Click View all Products');
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) =>
                                    AllProductScreen("")));
                      },
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 425,
                child: GridView.builder(
                    scrollDirection: Axis.vertical,
                    itemCount: _listProducts.length,
                    padding: const EdgeInsets.all(8.0),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 1,
                      crossAxisSpacing: 8.0,
                      mainAxisSpacing: 8.0,
                    ),
                    itemBuilder: (_, index) {
                      return GestureDetector(
                        onTap: () => {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) =>
                                      ProductDetails(_listProducts[index])))
                        },
                        child: Card(
                          elevation: 10,
                          child: Container(
                            alignment: Alignment.center,
                            padding: const EdgeInsets.all(4.0),
                            decoration: BoxDecoration(
                              color: Colors.white30,
                              borderRadius: BorderRadius.circular(20.0),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Container(
                                  alignment: Alignment.center,
                                  height: 125,
                                  width: 150,
                                  child: AspectRatio(
                                    aspectRatio: 1.3,
                                    child: Image.network(
                                      _listProducts[index]["productImage"][0],
                                    ),
                                  ),

                                ),
                                Text(
                                  "${_listProducts[index]["productName"]}",
                                  style: const TextStyle(
                                    color: Colors.deepOrange,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(oCcy.format(
                                    _listProducts[index]["productPrice"])),
                              ],
                            ),
                          ),
                        ),
                      );
                    }),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
