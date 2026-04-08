class ItemSupermercado {
  final String nome;
  final String quantidade;

  ItemSupermercado(this.nome, this.quantidade);

  @override
  String toString() {
    return 'ItemSupermercado{nome: $nome, quantidade: $quantidade}';
  }
}