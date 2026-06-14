class Produto {
  final int? id;
  final String nome;
  final String categoria;
  final double preco;
  final int estoque;
  final String unidade;

  Produto({
    this.id,
    required this.nome,
    required this.categoria,
    required this.preco,
    required this.estoque,
    this.unidade = 'un',
  });

  // Converte para Map (SQLite)
  Map<String, dynamic> toMap() => {
        if (id != null) 'id': id,
        'nome': nome,
        'categoria': categoria,
        'preco': preco,
        'estoque': estoque,
        'unidade': unidade,
      };

  // Cria a partir de Map (SQLite)
  factory Produto.fromMap(Map<String, dynamic> map) => Produto(
        id: map['id'] as int?,
        nome: map['nome'] as String,
        categoria: map['categoria'] as String,
        preco: (map['preco'] as num).toDouble(),
        estoque: map['estoque'] as int,
        unidade: map['unidade'] as String? ?? 'un',
      );

  // Cria a partir de JSON (API)
  factory Produto.fromJson(Map<String, dynamic> json) => Produto(
        id: json['id'] as int?,
        nome: json['nome'] as String,
        categoria: json['categoria'] as String,
        preco: (json['preco'] as num).toDouble(),
        estoque: json['estoque'] as int,
        unidade: json['unidade'] as String? ?? 'un',
      );

  // Converte para JSON (API)
  Map<String, dynamic> toJson() => {
        'nome': nome,
        'categoria': categoria,
        'preco': preco,
        'estoque': estoque,
        'unidade': unidade,
      };

  Produto copyWith({
    int? id,
    String? nome,
    String? categoria,
    double? preco,
    int? estoque,
    String? unidade,
  }) =>
      Produto(
        id: id ?? this.id,
        nome: nome ?? this.nome,
        categoria: categoria ?? this.categoria,
        preco: preco ?? this.preco,
        estoque: estoque ?? this.estoque,
        unidade: unidade ?? this.unidade,
      );
}
