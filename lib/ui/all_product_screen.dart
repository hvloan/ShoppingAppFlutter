import 'package:e_commerce_app/controller/bottom_nav_controller.dart';
import 'package:e_commerce_app/ui/bottom_nav_pages/home.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'detail_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AllProductScreen extends StatefulWidget {
  var _category;

  AllProductScreen(this._category);

  @override
  State<AllProductScreen> createState() => _AllProductScreenState();
}

class _AllProductScreenState extends State<AllProductScreen> {
  final _firestoreInstance = FirebaseFirestore.instance;
  final List _listProducts = [];
  final oCcy =
      NumberFormat.currency(locale: 'vi-VN', symbol: 'VND', decimalDigits: 0);

  checkQuery() {
    if (widget._category != "") {
      return _firestoreInstance
          .collection('dataProducts')
          .where("productType", isEqualTo: widget._category)
          .snapshots();
    } else {
      return _firestoreInstance.collection('dataProducts').snapshots();
    }
  }

  Widget buildStream() {
    return StreamBuilder(
        stream: checkQuery(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return const Center(
              child: Text("Something is wrong"),
            );
          } else if (snapshot.data == null) {
            return SizedBox(
              height: double.infinity,
              width: double.infinity,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.hourglass_empty_rounded,
                    color: Colors.grey,
                    size: 60.0,
                  ),
                  const SizedBox(height: 10.0),
                  const Text(
                    'Sorry, product is updating!!!',
                    style: TextStyle(fontSize: 24.0, color: Colors.grey),
                  ),
                  Text(widget._category.toString()),
                ],
              ),
            );
          }
          if (snapshot.data?.docs.length != null) {
            for (var i = 0; i < snapshot.data!.docs.length; i++) {
              DocumentSnapshot _documentSnapshot = snapshot.data!.docs[i];
              _listProducts.add({
                "productName": _documentSnapshot['productName'],
                "productImage": _documentSnapshot['productImage'],
                "productDescription": _documentSnapshot['productDescription'],
                "productQuantities": _documentSnapshot['productQuantities'],
                "productNumLikes": _documentSnapshot['productNumLikes'],
                "productPrice": _documentSnapshot['productPrice'],
                "productType": _documentSnapshot['productType'],
              });
            }
          }
          return (snapshot.data!.docs.isEmpty)
              ? SizedBox(
                  height: double.infinity,
                  width: double.infinity,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: const [
                      Icon(
                        Icons.hourglass_empty_rounded,
                        color: Colors.grey,
                        size: 60.0,
                      ),
                      SizedBox(height: 10.0),
                      Text(
                        'Sorry, product is updating!!!!!',
                        style: TextStyle(fontSize: 24.0, color: Colors.grey),
                      )
                    ],
                  ),
                )
              : Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      Expanded(
                        flex: 1,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            IconButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    CupertinoPageRoute(
                                        builder: (_) =>
                                            const BottomNavController()),
                                  );
                                },
                                icon: const Icon(Icons.arrow_back)),
                            Text(
                              widget._category.toString().toUpperCase(),
                              style: const TextStyle(
                                color: Colors.deepOrangeAccent,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(
                              width: 50,
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        flex: 9,
                        child: GridView.builder(
                            scrollDirection: Axis.vertical,
                            itemCount: _listProducts.length,
                            padding: const EdgeInsets.all(8.0),
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
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
                                          ProductDetails(_listProducts[index]),
                                    ),
                                  ),
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
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Container(
                                          alignment: Alignment.center,
                                          height: 125,
                                          width: 150,
                                          child: AspectRatio(
                                            aspectRatio: 1.3,
                                            child: Image.network(
                                              _listProducts[index]
                                                  ["productImage"][0],
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
                                        Text(oCcy.format(_listProducts[index]
                                            ["productPrice"])),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            }),
                      ),
                    ],
                  ),
                );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(child: buildStream()),
    );
  }
}
