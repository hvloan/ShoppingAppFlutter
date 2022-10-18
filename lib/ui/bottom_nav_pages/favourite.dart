import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:e_commerce_app/ui/detail_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';
import 'package:fluttertoast/fluttertoast.dart';

class Favourite extends StatefulWidget {
  const Favourite({Key? key}) : super(key: key);

  @override
  _FavouriteState createState() => _FavouriteState();
}

class _FavouriteState extends State<Favourite> {
  final oCcy =
      NumberFormat.currency(locale: 'vi-VN', symbol: 'VND', decimalDigits: 0);

  Widget buildChild(String collectionName) {
    return StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection(collectionName)
            .doc(FirebaseAuth.instance.currentUser!.email)
            .collection("items")
            .snapshots(),
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
                children: const [
                  Icon(
                    Icons.hourglass_empty_rounded,
                    color: Colors.grey,
                    size: 60.0,
                  ),
                  SizedBox(height: 10.0),
                  Text(
                    'Your favourite products is empty!!!',
                    style: TextStyle(fontSize: 24.0, color: Colors.grey),
                  )
                ],
              ),
            );
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
                        'Your favourite products is empty!!!',
                        style: TextStyle(fontSize: 24.0, color: Colors.grey),
                      )
                    ],
                  ),
                )
              : SingleChildScrollView(
                  child: Column(
                    children: [
                      ListView.separated(
                        shrinkWrap: true,
                        padding: const EdgeInsets.only(
                            top: 20, bottom: 20, left: 8, right: 8),
                        scrollDirection: Axis.vertical,
                        separatorBuilder: (BuildContext context, int index) =>
                            const Divider(),
                        itemCount: snapshot.data == null
                            ? 0
                            : snapshot.data!.docs.length,
                        itemBuilder: (BuildContext context, int index) {
                          DocumentSnapshot _documentSnapshot =
                              snapshot.data!.docs[index];
                          return Padding(
                            padding: (index == 0)
                                ? const EdgeInsets.symmetric(vertical: 10.0)
                                : const EdgeInsets.only(bottom: 20.0),
                            child: Slidable(
                              key: Key('$_documentSnapshot'),
                              endActionPane: ActionPane(
                                motion: const ScrollMotion(),
                                children: [
                                  SlidableAction(
                                    onPressed: (context) {},
                                    backgroundColor: Colors.teal,
                                    icon: Icons.share,
                                  ),
                                  SlidableAction(
                                    onPressed: (context) {
                                      addToCart(_documentSnapshot["name"], _documentSnapshot["images"], _documentSnapshot["price"]);
                                    },
                                    backgroundColor: Colors.limeAccent,
                                    icon: Icons.add_shopping_cart_sharp,
                                  ),
                                  SlidableAction(
                                    onPressed: (context) {
                                      setState(() {
                                        showDeleteAlertDialog(
                                            collectionName, _documentSnapshot);
                                      });
                                    },
                                    backgroundColor: Colors.red,
                                    icon: Icons.delete,
                                  ),
                                ],
                              ),
                              child: Container(
                                margin:
                                    const EdgeInsets.symmetric(horizontal: 8.0),
                                padding: const EdgeInsets.all(10.0),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10.0),
                                  color: Colors.white,
                                  boxShadow: const [
                                    BoxShadow(
                                      blurStyle: BlurStyle.solid,
                                      color: Colors.orangeAccent,
                                      blurRadius: 8.0,
                                      spreadRadius: 3.0,
                                      offset: Offset(
                                          2, 3), // changes position of shadow
                                    ),
                                  ],
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(10.0),
                                      child: Image.network(
                                        _documentSnapshot["images"][0],
                                        width: 100.0,
                                        height: 100.0,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                    const SizedBox(width: 10.0),
                                    Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          _documentSnapshot["name"],
                                          style: const TextStyle(
                                            fontSize: 18.0,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 10.0),
                                        Text(
                                          oCcy.format(
                                              _documentSnapshot["price"]),
                                          style: const TextStyle(
                                            fontSize: 14.0,
                                            color: Colors.grey,
                                          ),
                                        ),
                                        const SizedBox(
                                          height: 10,
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                    ],
                  ),
                );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(child: buildChild("usersFavouriteItems")),
    );
  }

  showDeleteAlertDialog(collectionName, _documentSnapshot) {
    AlertDialog alertDialog = AlertDialog(
      title: const Text("Alert"),
      content: const Text("Are you sure remove this product from your cart???"),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      actions: <Widget>[
        TextButton(
          onPressed: () => {Navigator.of(context).pop(false)},
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () => {
            FirebaseFirestore.instance
                .collection(collectionName)
                .doc(FirebaseAuth.instance.currentUser!.email)
                .collection("items")
                .doc(_documentSnapshot.id)
                .delete()
                .then((value) => {
                      Fluttertoast.showToast(
                        msg: "Product removed!!",
                        toastLength: Toast.LENGTH_SHORT,
                        gravity: ToastGravity.TOP,
                        timeInSecForIosWeb: 5,
                        backgroundColor: Colors.redAccent,
                      ),
                      Navigator.of(context).pop(false)
                    })
          },
          child: const Text('OK'),
        ),
      ],
    );
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alertDialog;
      },
    );
  }

  Future addToCart(name, image, price) async {
    final FirebaseAuth _auth = FirebaseAuth.instance;
    var currentUser = _auth.currentUser;
    CollectionReference _collectionRef =
    FirebaseFirestore.instance.collection("usersCartItems");
    return _collectionRef
        .doc(currentUser!.email)
        .collection("items")
        .doc()
        .set({
      "name": name,
      "price": price,
      "images": image,
      "numbers": 1,
    }).then((value) => Fluttertoast.showToast(
      msg: "Added to cart!!",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.TOP,
      timeInSecForIosWeb: 5,
      backgroundColor: Colors.redAccent,
    ));
  }
}
