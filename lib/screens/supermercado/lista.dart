import 'package:flutter/material.dart';
import '../../models/item_supermercado.dart';
import 'formulario.dart';

class ListaSupermercado extends StatefulWidget {
  final List<ItemSupermercado> _itens = [];

  ListaSupermercado({super.key});

  @override
  State<ListaSupermercado> createState() => _ListaSupermercadoState();
}

class _ListaSupermercadoState extends State<ListaSupermercado> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Minha Lista de Compras'),
      ),
      body: ListView.builder(
        itemCount: widget._itens.length,
        itemBuilder: (context, indice) {
          final item = widget._itens[indice];
          // REQUISITO: Cada item exibido em um Card
          return ItemDaLista(item);
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // REQUISITO: Abrir formulário com Navigator.push()
          Navigator.push(context, MaterialPageRoute(builder: (context) {
            return const FormularioItem();
          })).then((itemRecebido) {
            _atualiza(itemRecebido);
          });
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  // REQUISITO: Atualização via setState()
  void _atualiza(ItemSupermercado? itemRecebido) {
    if (itemRecebido != null) {
      setState(() {
        widget._itens.add(itemRecebido);
      });
    }
  }
}

class ItemDaLista extends StatelessWidget {
  final ItemSupermercado _item;

  const ItemDaLista(this._item, {super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        leading: const Icon(Icons.check_box_outline_blank, color: Colors.green),
        title: Text(_item.nome, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text('Quantidade: ${_item.quantidade}'),
      ),
    );
  }
}
