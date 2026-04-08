import 'package:flutter/material.dart';
import '../../components/editor.dart';
import '../../models/item_supermercado.dart';

class FormularioItem extends StatefulWidget {
  const FormularioItem({super.key});

  @override
  State<FormularioItem> createState() => _FormularioItemState();
}

class _FormularioItemState extends State<FormularioItem> {
  final TextEditingController _controladorCampoNome = TextEditingController();
  final TextEditingController _controladorCampoQuantidade = TextEditingController();

  void _criaItem(BuildContext context) {
    final String nome = _controladorCampoNome.text;
    final String quantidade = _controladorCampoQuantidade.text;

    if (nome.isNotEmpty && quantidade.isNotEmpty) {
      final itemCriado = ItemSupermercado(nome, quantidade);
      // REQUISITO: Retornar dados com Navigator.pop()
      Navigator.pop(context, itemCriado);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Adicionar à Lista'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Editor(
              controlador: _controladorCampoNome,
              rotulo: 'Nome do Item',
              dica: 'Ex: Arroz',
              icone: Icons.shopping_basket,
            ),
            Editor(
              controlador: _controladorCampoQuantidade,
              rotulo: 'Quantidade',
              dica: 'Ex: 2kg ou 1 unidade',
              icone: Icons.production_quantity_limits,
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton(
                onPressed: () => _criaItem(context),
                child: const Text('Salvar'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
