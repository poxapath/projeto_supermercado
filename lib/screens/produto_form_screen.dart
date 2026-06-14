import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/produto.dart';
import '../services/produto_service.dart';
import '../theme/app_theme.dart';

class ProdutoFormScreen extends StatefulWidget {
  final Produto? produto;
  const ProdutoFormScreen({super.key, this.produto});

  @override
  State<ProdutoFormScreen> createState() => _ProdutoFormScreenState();
}

class _ProdutoFormScreenState extends State<ProdutoFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _service = ProdutoService();

  late TextEditingController _nomeCtrl;
  late TextEditingController _precoCtrl;
  late TextEditingController _estoqueCtrl;

  late String _categoria;
  late String _unidade;
  bool _salvando = false;

  bool get _editando => widget.produto != null;

  static const _categorias = [
    'Hortifruti',
    'Laticínios',
    'Carnes',
    'Bebidas',
    'Limpeza',
    'Higiene',
    'Padaria',
    'Outros',
  ];

  static const _unidades = ['un', 'kg', 'g', 'L', 'ml', 'cx', 'pc'];

  @override
  void initState() {
    super.initState();
    final p = widget.produto;
    _nomeCtrl = TextEditingController(text: p?.nome ?? '');
    _precoCtrl = TextEditingController(
      text: p != null ? p.preco.toStringAsFixed(2) : '',
    );
    _estoqueCtrl = TextEditingController(
      text: p != null ? p.estoque.toString() : '',
    );
    _categoria = p?.categoria ?? 'Outros';
    _unidade = p?.unidade ?? 'un';
  }

  @override
  void dispose() {
    _nomeCtrl.dispose();
    _precoCtrl.dispose();
    _estoqueCtrl.dispose();
    super.dispose();
  }

  Future<void> _salvar() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _salvando = true);
    final produto = Produto(
      id: widget.produto?.id,
      nome: _nomeCtrl.text.trim(),
      categoria: _categoria,
      preco: double.parse(_precoCtrl.text.replaceAll(',', '.')),
      estoque: int.parse(_estoqueCtrl.text),
      unidade: _unidade,
    );
    try {
      if (_editando) {
        await _service.atualizar(produto);
      } else {
        await _service.criar(produto);
      }
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao salvar: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _salvando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_editando ? 'Editar Produto' : 'Novo Produto'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildCard(
                titulo: 'Informações do Produto',
                icone: Icons.inventory_2_outlined,
                children: [
                  TextFormField(
                    controller: _nomeCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Nome do produto *',
                      prefixIcon: Icon(Icons.label_outline),
                    ),
                    textCapitalization: TextCapitalization.words,
                    validator: (v) =>
                        v == null || v.trim().isEmpty ? 'Informe o nome' : null,
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: _categoria,
                    decoration: const InputDecoration(
                      labelText: 'Categoria *',
                      prefixIcon: Icon(Icons.category_outlined),
                    ),
                    items: _categorias
                        .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                        .toList(),
                    onChanged: (v) => setState(() => _categoria = v!),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _buildCard(
                titulo: 'Preço e Estoque',
                icone: Icons.attach_money,
                children: [
                  TextFormField(
                    controller: _precoCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Preço (R\$) *',
                      prefixIcon: Icon(Icons.monetization_on_outlined),
                      hintText: '0,00',
                    ),
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[\d,\.]')),
                    ],
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'Informe o preço';
                      final parsed = double.tryParse(v.replaceAll(',', '.'));
                      if (parsed == null || parsed < 0) return 'Preço inválido';
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: TextFormField(
                          controller: _estoqueCtrl,
                          decoration: const InputDecoration(
                            labelText: 'Estoque *',
                            prefixIcon: Icon(Icons.warehouse_outlined),
                          ),
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                          validator: (v) {
                            if (v == null || v.isEmpty) {
                              return 'Informe o estoque';
                            }
                            if (int.tryParse(v) == null) {
                              return 'Número inválido';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: _unidade,
                          decoration:
                              const InputDecoration(labelText: 'Unidade'),
                          items: _unidades
                              .map((u) =>
                                  DropdownMenuItem(value: u, child: Text(u)))
                              .toList(),
                          onChanged: (v) => setState(() => _unidade = v!),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _salvando ? null : _salvar,
                icon: _salvando
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.save_outlined),
                label: Text(_salvando
                    ? 'Salvando...'
                    : _editando
                        ? 'Salvar Alterações'
                        : 'Cadastrar Produto'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCard({
    required String titulo,
    required IconData icone,
    required List<Widget> children,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icone, color: AppTheme.primary, size: 20),
                const SizedBox(width: 8),
                Text(
                  titulo,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: AppTheme.primary,
                  ),
                ),
              ],
            ),
            const Divider(height: 20),
            ...children,
          ],
        ),
      ),
    );
  }
}
