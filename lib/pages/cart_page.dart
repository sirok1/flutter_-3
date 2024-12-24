import 'package:flutter/material.dart';
import 'package:flutter_4/models/cart_item.dart';
import 'package:flutter_4/models/game.dart';
import 'package:flutter_4/models/order.dart';
import 'package:flutter_4/services/api_service.dart';

class CartPage extends StatefulWidget {
  final List<CartItem> cart;
  final Function(Game) removeFromCart;
  final Function(Game) addToCart;
  final Function() clearCart;
  const CartPage(
      {super.key,
      required this.cart,
      required this.removeFromCart,
      required this.addToCart,
      required this.clearCart});

  @override
  State<StatefulWidget> createState() => _CartPage();
}

class _CartPage extends State<CartPage> {
  final apiService = ApiService();

  void createOrder() async {
    try {
      List<Order> orders = widget.cart.map((item) {
        return Order(
          id: UniqueKey().toString(),
          productId: item.data.id,
          quantity: item.quantity,
          total: (item.data.price * item.quantity).toDouble(),
          createdAt: DateTime.now(),
        );
      }).toList();

      await apiService.createOrder(orders);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Покупка совершена"),
        ),
      );
      widget.clearCart();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Ошибка при создании заказа: $e"),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: const Text("Корзина",
              style: TextStyle(fontWeight: FontWeight.bold)),
        ),
        body: widget.cart.isEmpty
            ? const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.shopping_bag,
                      size: 50,
                      color: Colors.grey,
                    ),
                    SizedBox(height: 16),
                    Text(
                      "Здесь пока ничего нет(",
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),
              )
            : Column(children: [
                Expanded(
                    child: Padding(
                  padding: const EdgeInsets.fromLTRB(10, 0, 10, 10),
                  child: ListView.builder(
                      itemCount: widget.cart.length,
                      itemBuilder: (BuildContext context, int index) {
                        return Dismissible(
                            key: Key(widget.cart[index].id),
                            direction: DismissDirection.endToStart,
                            background: Container(
                              color: Colors.red,
                              alignment: Alignment.centerRight,
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 20),
                              child: const Icon(
                                Icons.delete,
                                color: Colors.white,
                              ),
                            ),
                            confirmDismiss: (direction) async {
                              return await showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: const Text('Подтверждение удаления'),
                                  content: const Text(
                                      'Вы уверены, что хотите удалить этот элемент из корзины?'),
                                  actions: [
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.of(context).pop(false),
                                      child: const Text('Отмена'),
                                    ),
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.of(context).pop(true),
                                      child: const Text('Удалить'),
                                    ),
                                  ],
                                ),
                              );
                            },
                            onDismissed: (direction) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                      "${widget.cart[index].data.name} удален из корзины"),
                                ),
                              );
                              widget.removeFromCart(widget.cart[index].data);
                            },
                            child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      SizedBox(
                                          height: 40,
                                          width: 80,
                                          child: AspectRatio(
                                            aspectRatio: 9 / 15,
                                            child: Container(
                                              decoration: BoxDecoration(
                                                  image: DecorationImage(
                                                      image: NetworkImage(widget
                                                          .cart[index]
                                                          .data
                                                          .imageUrl),
                                                      fit: BoxFit.cover),
                                                  borderRadius:
                                                      const BorderRadius.all(
                                                          Radius.circular(8))),
                                            ),
                                          )),
                                      const SizedBox(
                                        width: 10,
                                      ),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(widget.cart[index].data.name),
                                          Text(
                                            '${widget.cart[index].quantity} x ${widget.cart[index].data.price} руб.',
                                            style: const TextStyle(
                                                color: Colors.grey),
                                          )
                                        ],
                                      ),
                                    ],
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      IconButton(
                                        onPressed: () => widget.removeFromCart(
                                            widget.cart[index].data),
                                        icon: const Icon(Icons.remove),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 10),
                                        child: Text(
                                          widget.cart[index].quantity
                                              .toString(),
                                          style: const TextStyle(fontSize: 20),
                                        ),
                                      ),
                                      IconButton(
                                        onPressed: () => widget
                                            .addToCart(widget.cart[index].data),
                                        icon: const Icon(Icons.add),
                                      ),
                                    ],
                                  )
                                ]));
                      }),
                )),
                Align(
                    alignment: Alignment.bottomCenter,
                    child: SizedBox(
                      width: MediaQuery.of(context).size.width,
                      child: FloatingActionButton.extended(
                        backgroundColor: Colors.blueGrey,
                        onPressed: createOrder,
                        label: Text(
                          'Оплатить ${widget.cart.map((position) => position.data.price * (position.quantity > 0 ? position.quantity : 1)).reduce((a, b) => a + b).toString()} руб.',
                          style: const TextStyle(color: Colors.white),
                        ),
                        shape: const RoundedRectangleBorder(),
                      ),
                    ))
              ]));
  }
}
