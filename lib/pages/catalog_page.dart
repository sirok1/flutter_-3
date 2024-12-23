import 'package:flutter/material.dart';
import 'package:flutter_4/api/api_service.dart';
import 'package:flutter_4/components/game_item.dart';
import 'package:flutter_4/models/cart_item.dart';
import 'package:flutter_4/models/game.dart';

class CatalogPage extends StatefulWidget {
  final Function(Game) onFavoriteToggle;
  final List<Game> favoriteGames;
  final List<CartItem> cart;
  final Function(Game) addToCart;
  final Function(Game) removeFromCart;

  const CatalogPage(
      {super.key,
      required this.onFavoriteToggle,
      required this.favoriteGames,
      required this.cart,
      required this.addToCart,
      required this.removeFromCart});

  @override
  _CatalogPageState createState() => _CatalogPageState();
}

class _CatalogPageState extends State<CatalogPage> {
  late Future<List<Game>> _games;

  void _showAddGameDialog() {
    final TextEditingController idController = TextEditingController();
    final TextEditingController titleController = TextEditingController();
    final TextEditingController descriptionController = TextEditingController();
    final TextEditingController imageUrlController = TextEditingController();
    final TextEditingController priceController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Добавить новую игру'),
          content: SingleChildScrollView(
              child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: idController,
                decoration: const InputDecoration(labelText: 'Артикул'),
              ),
              TextField(
                controller: titleController,
                decoration: const InputDecoration(labelText: 'Название'),
              ),
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(labelText: 'Описание'),
              ),
              TextField(
                controller: imageUrlController,
                decoration: const InputDecoration(labelText: 'URL изображения'),
              ),
              TextField(
                controller: priceController,
                decoration: const InputDecoration(labelText: 'Цена'),
              ),
            ],
          )),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Отмена'),
            ),
            TextButton(
              onPressed: () async {
                final newGame = Game(
                  idController.text,
                  titleController.text,
                  descriptionController.text,
                  imageUrlController.text,
                  int.parse(priceController.text),
                );

                final gameFromApi = await ApiService().addGame(newGame);
                final currentGames = await _games;

                setState(() {
                  _games = Future.value([...currentGames, gameFromApi]);
                });

                Navigator.of(context).pop();
              },
              child: const Text('Сохранить'),
            ),
          ],
        );
      },
    );
  }

  void _removeFromGames(Game game) {
    setState(() {
      _games = Future.value(_games.then((gameList) {
        gameList.remove(game);
        return gameList;
      }));
    });
  }

  @override
  void initState() {
    super.initState();
    _games = ApiService().getProducts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: const Text(
            "Каталог игр",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: FutureBuilder<List<Game>>(
            future: _games,
            builder:
                (BuildContext context, AsyncSnapshot<List<Game>> snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(child: Text('Нет игр в каталоге.'));
              }

              final games = snapshot.data!;

              return GridView.builder(
                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 200,
                  childAspectRatio: 6 / 12,
                  crossAxisSpacing: 20,
                  mainAxisSpacing: 20,
                ),
                itemCount: games.length,
                itemBuilder: (BuildContext ctx, index) {
                  return Dismissible(
                    key: Key(games[index].id),
                    direction: DismissDirection.endToStart,
                    background: Container(
                      color: Colors.red,
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
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
                              'Вы уверены, что хотите удалить этот элемент из каталога?'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(false),
                              child: const Text('Отмена'),
                            ),
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(true),
                              child: const Text('Удалить'),
                            ),
                          ],
                        ),
                      );
                    },
                    onDismissed: (direction) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content:
                              Text("${games[index].name} удален из каталога"),
                        ),
                      );
                      _removeFromGames(games[index]);
                    },
                    child: GameItem(
                      game: games[index],
                      liked: widget.favoriteGames.contains(games[index]),
                      onFavoriteToggle: () =>
                          widget.onFavoriteToggle(games[index]),
                      quantityInCart: widget.cart
                          .firstWhere(
                            (position) => position.id == games[index].id,
                            orElse: () =>
                                CartItem(games[index].id, 0, games[index]),
                          )
                          .quantity,
                      addToCart: () => widget.addToCart(games[index]),
                      removeFromCart: () => widget.removeFromCart(games[index]),
                    ),
                  );
                },
              );
            },
          ),
        ),
        floatingActionButton: Stack(
          children: [
            Positioned(
              bottom: 40,
              right: 0,
              child: SizedBox(
                height: 70,
                width: 70,
                child: FloatingActionButton(
                  onPressed: () => _showAddGameDialog(),
                  backgroundColor: Colors.blueGrey,
                  foregroundColor: Colors.white,
                  enableFeedback: true,
                  child: const Icon(Icons.add),
                ),
              ),
            ),
          ],
        ));
  }
}
