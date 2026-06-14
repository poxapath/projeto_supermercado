import 'package:flutter/material.dart';
import '../models/produto.dart';
import '../services/produto_service.dart';
import '../theme/app_theme.dart';
import 'produto_form_screen.dart';
import 'produto_detalhe_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _service = ProdutoService();
  List<Produto> _produtos = [];
  List<Produto> _produtosFiltrados = [];
  bool _carregando = true;
  bool _apiOnline = false;
  String _filtroCategoria = 'Todos';
  final _buscaController = TextEditingController();

  static const _categorias = [
    'Todos', 'Hortifruti', 'Laticínios', 'Carnes',
    'Bebidas', 'Limpeza', 'Higiene', 'Padaria', 'Outros',
  ];

  @override
  void initState() {
    super.initState();
    _carregar();
    _buscaController.addListener(_filtrar);
  }

  @override
  void dispose() {
    _buscaController.dispose();
    super.dispose();
  }

  Future<void> _carregar() async {
    setState(() => _carregando = true);
    final online = await _service.checarConexaoApi();
    final lista = online
        ? await _service.listarRemoto()
        : await _service.listarLocal();
    setState(() {
      _apiOnline = online;
      _produtos = lista;
      _carregando = false;
    });
    _filtrar();
  }

  void _filtrar() {
    final busca = _buscaController.text.toLowerCase();
    setState(() {
      _produtosFiltrados = _produtos.where((p) {
        final matchNome = p.nome.toLowerCase().contains(busca);
        final matchCategoria =
            _filtroCategoria == 'Todos' || p.categoria == _filtroCategoria;
        return matchNome && matchCategoria;
      }).toList();
    });
  }

  void _selecionarCategoria(String cat) {
    setState(() => _filtroCategoria = cat);
    _filtrar();
  }

  Future<void> _excluir(Produto produto) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Excluir produto'),
        content: Text('Deseja excluir "${produto.nome}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: AppTheme.error),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
    if (confirmar == true) {
      await _service.excluir(produto.id!);
      _carregar();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('"${produto.nome}" excluído.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🛒 Supermercado'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Chip(
              avatar: Icon(
                _apiOnline ? Icons.cloud_done : Icons.cloud_off,
                size: 16,
                color: _apiOnline ? Colors.green[200] : Colors.orange[200],
              ),
              label: Text(
                _apiOnline ? 'Online' : 'Local',
                style: const TextStyle(color: Colors.white, fontSize: 12),
              ),
              backgroundColor: Colors.white24,
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildBusca(),
          _buildFiltrosCategorias(),
          _buildResumo(),
          Expanded(
            child: _carregando
                ? const Center(child: CircularProgressIndicator())
                : _produtosFiltrados.isEmpty
                    ? _buildVazio()
                    : _buildLista(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const ProdutoFormScreen()),
          );
          _carregar();
        },
        icon: const Icon(Icons.add),
        label: const Text('Novo Produto'),
      ),
    );
  }

  Widget _buildBusca() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 4),
      child: TextField(
        controller: _buscaController,
        decoration: const InputDecoration(
          hintText: 'Buscar produto...',
          prefixIcon: Icon(Icons.search),
        ),
      ),
    );
  }

  Widget _buildFiltrosCategorias() {
    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        itemCount: _categorias.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, i) {
          final cat = _categorias[i];
          final selecionado = cat == _filtroCategoria;
          return FilterChip(
            label: Text(cat),
            selected: selecionado,
            onSelected: (_) => _selecionarCategoria(cat),
            selectedColor: AppTheme.primary,
            labelStyle: TextStyle(
              color: selecionado ? Colors.white : AppTheme.primary,
              fontWeight: FontWeight.w500,
            ),
            checkmarkColor: Colors.white,
          );
        },
      ),
    );
  }

  Widget _buildResumo() {
    final totalItens = _produtosFiltrados.length;
    final baixoEstoque = _produtosFiltrados.where((p) => p.estoque < 5).length;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Row(
        children: [
          Text(
            '$totalItens produto${totalItens != 1 ? 's' : ''}',
            style: TextStyle(color: Colors.grey[600], fontSize: 13),
          ),
          if (baixoEstoque > 0) ...[
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.orange[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '⚠️ $baixoEstoque com estoque baixo',
                style: TextStyle(color: Colors.orange[800], fontSize: 12),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildLista() {
    return RefreshIndicator(
      onRefresh: _carregar,
      child: ListView.builder(
        padding: const EdgeInsets.only(bottom: 80),
        itemCount: _produtosFiltrados.length,
        itemBuilder: (_, i) => _buildCard(_produtosFiltrados[i]),
      ),
    );
  }

  Widget _buildCard(Produto produto) {
    final estoqueColor = produto.estoque < 5
        ? Colors.orange
        : produto.estoque == 0
            ? Colors.red
            : AppTheme.primary;

    return Card(
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: const Color.fromRGBO(27, 94, 32, 0.1),
          child: Text(
            produto.nome[0].toUpperCase(),
            style: const TextStyle(
              color: AppTheme.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(
          produto.nome,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 2),
            Chip(
              label:
                  Text(produto.categoria, style: const TextStyle(fontSize: 11)),
              padding: EdgeInsets.zero,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            const SizedBox(height: 2),
            Text(
              'Estoque: ${produto.estoque} ${produto.unidade}',
              style: TextStyle(color: estoqueColor, fontSize: 12),
            ),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              'R\$ ${produto.preco.toStringAsFixed(2)}',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15,
                color: AppTheme.primary,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                GestureDetector(
                  onTap: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ProdutoFormScreen(produto: produto),
                      ),
                    );
                    _carregar();
                  },
                  child: const Icon(Icons.edit,
                      size: 20, color: AppTheme.primary),
                ),
                const SizedBox(width: 12),
                GestureDetector(
                  onTap: () => _excluir(produto),
                  child: const Icon(Icons.delete_outline,
                      size: 20, color: AppTheme.error),
                ),
              ],
            ),
          ],
        ),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ProdutoDetalheScreen(produto: produto),
          ),
        ),
      ),
    );
  }

  Widget _buildVazio() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.shopping_cart_outlined,
              size: 72, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            'Nenhum produto encontrado',
            style: TextStyle(color: Colors.grey[500], fontSize: 16),
          ),
          const SizedBox(height: 8),
          TextButton.icon(
            onPressed: _carregar,
            icon: const Icon(Icons.refresh),
            label: const Text('Recarregar'),
          ),
        ],
      ),
    );
  }
}
