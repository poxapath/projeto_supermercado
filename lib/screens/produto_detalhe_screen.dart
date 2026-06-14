import 'package:flutter/material.dart';
import '../models/produto.dart';
import '../theme/app_theme.dart';
import 'produto_form_screen.dart';

class ProdutoDetalheScreen extends StatelessWidget {
  final Produto produto;
  const ProdutoDetalheScreen({super.key, required this.produto});

  @override
  Widget build(BuildContext context) {
    final estoqueStatus = produto.estoque == 0
        ? ('Sem estoque', Colors.red)
        : produto.estoque < 5
            ? ('Estoque baixo', Colors.orange)
            : ('Em estoque', AppTheme.primary);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalhes do Produto'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            tooltip: 'Editar',
            onPressed: () => Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) => ProdutoFormScreen(produto: produto),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    const CircleAvatar(
                      radius: 36,
                      backgroundColor: Color.fromRGBO(27, 94, 32, 0.1),
                      child: Text(
                        '?',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primary,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      produto.nome,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 4),
                    Chip(label: Text(produto.categoria)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _buildDetalhe(
                      Icons.monetization_on_outlined,
                      'Preço',
                      'R\$ ${produto.preco.toStringAsFixed(2)}',
                      AppTheme.primary,
                    ),
                    const Divider(),
                    _buildDetalhe(
                      Icons.warehouse_outlined,
                      'Estoque',
                      '${produto.estoque} ${produto.unidade}',
                      estoqueStatus.$2,
                      badge: estoqueStatus.$1,
                      badgeColor: estoqueStatus.$2,
                    ),
                    const Divider(),
                    _buildDetalhe(
                      Icons.category_outlined,
                      'Categoria',
                      produto.categoria,
                      Colors.grey[700]!,
                    ),
                    if (produto.id != null) ...[
                      const Divider(),
                      _buildDetalhe(
                        Icons.tag,
                        'ID',
                        '#${produto.id}',
                        Colors.grey[500]!,
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetalhe(
    IconData icone,
    String label,
    String valor,
    Color cor, {
    String? badge,
    Color? badgeColor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Icon(icone, color: AppTheme.primary, size: 22),
          const SizedBox(width: 12),
          Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 14)),
          const Spacer(),
          Text(
            valor,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 15,
              color: cor,
            ),
          ),
          if (badge != null) ...[
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: Color.fromRGBO(
                  (badgeColor?.r ?? 0).round(),
                  (badgeColor?.g ?? 0).round(),
                  (badgeColor?.b ?? 0).round(),
                  0.1,
                ),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: badgeColor ?? Colors.grey),
              ),
              child: Text(
                badge,
                style: TextStyle(
                  color: badgeColor,
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
