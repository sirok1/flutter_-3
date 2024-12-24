import 'package:flutter/material.dart';
import 'package:flutter_4/models/order.dart';
import 'package:flutter_4/services/api_service.dart';
import 'package:intl/intl.dart';

class OrdersPage extends StatefulWidget {
  @override
  _OrdersPageState createState() => _OrdersPageState();
}

class _OrdersPageState extends State<OrdersPage> {
  final apiService = ApiService();
  List<Order> _orders = [];
  bool _empty = false;

  @override
  void initState() {
    super.initState();
    fetchOrders();
  }

  void fetchOrders() async {
    try {
      final orders = await apiService.getOrders();
      setState(() {
        if (orders.isEmpty) {
          _empty = true;
        }
        _orders = orders;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Не удалось загрузить заказы')));
      }
    }
  }

  String formatDate(DateTime date) {
    final DateFormat formatter = DateFormat('dd.MM.yyyy HH:mm');
    return formatter.format(date);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('История заказов'),
      ),
      body: _empty
          ? const Padding(
              padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
              child: Center(
                child: Text('Вы ещё не сделали ни одного заказа'),
              ),
            )
          : _orders.isEmpty
              ? const Center(child: CircularProgressIndicator())
              : ListView.builder(
                  itemCount: _orders.length,
                  itemBuilder: (BuildContext context, int index) {
                    final order = _orders[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(10),
                        title: Text(
                          'Заказ №${order.id}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text('Сумма: ${order.total} руб.'),
                        trailing: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.calendar_today, size: 16),
                            const SizedBox(height: 5),
                            Text(formatDate(order.createdAt)),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
