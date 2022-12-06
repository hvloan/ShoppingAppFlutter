import 'dart:collection';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:e_commerce_app/widgets/address_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';
import 'package:fluttertoast/fluttertoast.dart';

class Cart extends StatefulWidget {
  const Cart({Key? key}) : super(key: key);

  @override
  _CartState createState() => _CartState();
}

class _CartState extends State<Cart> {
  TextEditingController textEditingController = TextEditingController();
  final oCcy =
      NumberFormat.currency(locale: 'vi-VN', symbol: 'VND', decimalDigits: 0);
  int totalAmount = 0;
  var currentUser = FirebaseAuth.instance.currentUser;
  String valueInputTextDialog = "";
  var receiverName = "";
  var receiverPhone = "";
  var receiverAddress = "";
  List<ItemListCart> listCartProduct = [];

  void _setValueFromDialogToReceiverName() {
    setState(() {
      receiverName = valueInputTextDialog;
    });
  }

  void _setValueFromDialogToReceiverPhone() {
    setState(() {
      receiverPhone = valueInputTextDialog;
    });
  }

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
                    'Your cart is empty!!!',
                    style: TextStyle(fontSize: 24.0, color: Colors.grey),
                  )
                ],
              ),
            );
          }
          if (snapshot.data?.docs.length != null) {
            totalAmount = 0;
            listCartProduct.clear();
            for (var i = 0; i < snapshot.data!.docs.length; i++) {
              DocumentSnapshot _documentSnapshot = snapshot.data!.docs[i];
              totalAmount += _documentSnapshot["numbers"] *
                  _documentSnapshot["price"] as int;
              listCartProduct.add(ItemListCart(
                imageItem: _documentSnapshot["images"][0],
                nameItem: _documentSnapshot["name"],
                priceItem: _documentSnapshot["price"],
                numberItem: _documentSnapshot["numbers"],
              ));
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
                        'Your cart is empty!!!',
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
                                        Row(
                                          children: [
                                            GestureDetector(
                                              child: const CircleAvatar(
                                                radius: 18,
                                                child: Icon(Icons
                                                    .exposure_minus_1_rounded),
                                              ),
                                              onTap: () {
                                                if (_documentSnapshot[
                                                        "numbers"] <=
                                                    1) {
                                                } else {
                                                  FirebaseFirestore.instance
                                                      .collection(
                                                          collectionName)
                                                      .doc(FirebaseAuth.instance
                                                          .currentUser!.email)
                                                      .collection("items")
                                                      .doc(_documentSnapshot.id)
                                                      .update({
                                                    "numbers":
                                                        _documentSnapshot[
                                                                "numbers"] -
                                                            1
                                                  }).whenComplete(() async {
                                                    print("Completed");
                                                  }).catchError(
                                                          (e) => print(e));
                                                }
                                              },
                                            ),
                                            const SizedBox(
                                              width: 8,
                                            ),
                                            CircleAvatar(
                                              backgroundColor:
                                                  Colors.deepOrange,
                                              radius: 15,
                                              child: CircleAvatar(
                                                backgroundColor: Colors.white,
                                                radius: 13,
                                                child: Text(
                                                  _documentSnapshot["numbers"]
                                                      .toString(),
                                                  style: const TextStyle(
                                                    color: Colors.deepOrange,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 14,
                                                  ),
                                                ),
                                              ),
                                            ),
                                            const SizedBox(
                                              width: 8,
                                            ),
                                            GestureDetector(
                                              child: const CircleAvatar(
                                                radius: 18,
                                                backgroundColor:
                                                    Colors.deepOrange,
                                                child: Icon(
                                                    Icons.plus_one_rounded),
                                              ),
                                              onTap: () {
                                                FirebaseFirestore.instance
                                                    .collection(collectionName)
                                                    .doc(FirebaseAuth.instance
                                                        .currentUser!.email)
                                                    .collection("items")
                                                    .doc(_documentSnapshot.id)
                                                    .update({
                                                  "numbers": _documentSnapshot[
                                                          "numbers"] +
                                                      1
                                                }).whenComplete(() async {
                                                  print("Completed");
                                                }).catchError((e) => print(e));
                                              },
                                            ),
                                          ],
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
                      Container(
                        margin: const EdgeInsets.all(10.0),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10.0),
                          color: Colors.white,
                          boxShadow: const [
                            BoxShadow(
                              blurStyle: BlurStyle.solid,
                              color: Colors.black,
                              blurRadius: 8.0,
                              spreadRadius: 1.0,
                              offset:
                                  Offset(0, 0), // changes position of shadow
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(
                                  top: 10.0, left: 10.0, right: 10.0),
                              child: Column(
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: const [
                                      Text(
                                        "Receiver name: ",
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Text(
                                        receiverName,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18,
                                        ),
                                      ),
                                      const SizedBox(
                                        width: 4,
                                      ),
                                      IconButton(
                                        icon:
                                            const Icon(Icons.edit_note_rounded),
                                        onPressed: () async {
                                          await displayInputTextDialog(
                                            context,
                                            "Edit receiver name",
                                            "Enter your name!",
                                          );
                                          _setValueFromDialogToReceiverName();
                                        },
                                      ),
                                    ],
                                  ),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: const [
                                      Text(
                                        "Receiver phone number: ",
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Text(
                                        receiverPhone,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18,
                                        ),
                                      ),
                                      const SizedBox(
                                        width: 4,
                                      ),
                                      IconButton(
                                        icon:
                                            const Icon(Icons.edit_note_rounded),
                                        onPressed: () async {
                                          await displayInputTextDialog(
                                            context,
                                            "Edit receiver phone number",
                                            "Enter phone number!",
                                          );
                                          _setValueFromDialogToReceiverPhone();
                                        },
                                      ),
                                    ],
                                  ),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: const [
                                      Expanded(
                                        flex: 1,
                                        child: Text(
                                          "Receiver address: ",
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Expanded(
                                        flex: 1,
                                        child: AddressPicker(
                                          onAddressChanged: (LocalAddress) {
                                            receiverAddress =
                                                LocalAddress.toString();
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      const Text(
                                        "Amount: ",
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                      Text(
                                        oCcy.format(totalAmount),
                                        style: const TextStyle(
                                          color: Colors.deepOrange,
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(
                                    height: 10,
                                  ),
                                ],
                              ),
                            )
                          ],
                        ),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Container(
                        margin: const EdgeInsets.only(left: 8, right: 8),
                        width: MediaQuery.of(context).size.width,
                        height: 56,
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.price_check_rounded),
                          onPressed: () => {
                            orderCartItems(listCartProduct, receiverName,
                                receiverPhone, receiverAddress, totalAmount),
                          },
                          style: ElevatedButton.styleFrom(
                            primary: Colors.deepOrange,
                            elevation: 3,
                          ),
                          label: const Text(
                            "Checkout",
                            style: TextStyle(color: Colors.white, fontSize: 18),
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                    ],
                  ),
                );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(child: buildChild("usersCartItems")),
    );
  }

  displayInputTextDialog(
      BuildContext context, String title, String hint) async {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text(title),
            content: TextField(
              decoration: InputDecoration(hintText: hint),
              controller: textEditingController,
            ),
            actions: [
              TextButton(
                child: const Text('Cancel'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              TextButton(
                child: const Text('Ok'),
                onPressed: () {
                  valueInputTextDialog = textEditingController.text;
                  Navigator.of(context).pop(valueInputTextDialog);
                  textEditingController.clear();
                },
              ),
            ],
          );
        });
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
}

orderCartItems(List<ItemListCart> listCartProduct, String receiverName,
    String receiverPhone, String receiverAddress, int totalAmount) {
  final oCcy =
      NumberFormat.currency(locale: 'vi-VN', symbol: 'VND', decimalDigits: 0);
  final hashMap = <String, String>{};
  DateTime now = DateTime.now();
  String formattedDate = DateFormat('kk:mm:ss EEE d MMM').format(now);

  print("size: ${listCartProduct.length}");

  for (var i = 0; i < listCartProduct.length; i++) {
    hashMap["itemOrder - ${i + 1}"] =
        "${listCartProduct[i].nameItem} (${listCartProduct[i].numberItem})";
  }
  hashMap["receiverName"] = receiverName;
  hashMap["receiverPhone"] = receiverPhone;
  hashMap["receiverAddress"] = receiverAddress;
  hashMap["totalAmount"] = oCcy.format(totalAmount);
  print(hashMap);

  final FirebaseAuth _auth = FirebaseAuth.instance;
  var currentUser = _auth.currentUser;
  CollectionReference _collectionRef =
      FirebaseFirestore.instance.collection("usersOrderCart");
  return _collectionRef
      .doc(currentUser!.email)
      .collection(formattedDate)
      .doc()
      .set(hashMap)
      .then((value) => {
            Fluttertoast.showToast(
              msg: "Order successfully!!",
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.TOP,
              timeInSecForIosWeb: 5,
              backgroundColor: Colors.redAccent,
            ),
            batchDelete("usersCartItems"),
          });
}

Future<void> batchDelete(String collectionName) {
  var collection = FirebaseFirestore.instance.collection(collectionName).doc(FirebaseAuth.instance.currentUser!.email).collection("items");
  WriteBatch batch = FirebaseFirestore.instance.batch();

  return collection.get().then((querySnapshot) {
    for (var document in querySnapshot.docs) {
      batch.delete(document.reference);
    }

    return batch.commit();
  });
}

class ItemListCart {
  String imageItem, nameItem;
  int priceItem, numberItem;

  ItemListCart(
      {required this.imageItem,
      required this.nameItem,
      required this.priceItem,
      required this.numberItem});

  Map<String, dynamic> toMap() {
    return {
      'imageItem': imageItem,
      'nameItem': nameItem,
      'priceItem': priceItem,
      'numberItem': numberItem,
    };
  }

  factory ItemListCart.fromSnapshot(DocumentSnapshot docSnapshot) {
    return ItemListCart(
      imageItem: docSnapshot.get('images')[0],
      nameItem: docSnapshot.get('name'),
      priceItem: docSnapshot.get('price'),
      numberItem: docSnapshot.get('numbers'),
    );
  }
}
