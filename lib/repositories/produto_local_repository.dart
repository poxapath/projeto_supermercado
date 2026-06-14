import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/produto.dart';

/// Repositório local — persiste dados com SQLite no dispositivo.
class ProdutoLocalRepository {
  static Database? _db;

  Future<Database> get database async {
    _db ??= await _initDb();
    return _db!;
  }

  Future<Database> _initDb() async {
    final path = join(await getDatabasesPath(), 'supermercado.db');
    return openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE produtos (
            id       INTEGER PRIMARY KEY AUTOINCREMENT,
            nome     TEXT    NOT NULL,
            categoria TEXT   NOT NULL,
            preco    REAL    NOT NULL,
            estoque  INTEGER NOT NULL DEFAULT 0,
            unidade  TEXT    NOT NULL DEFAULT 'un'
          )
        ''');
      },
    );
  }

  // CREATE
  Future<Produto> inserir(Produto produto) async {
    final db = await database;
    final id = await db.insert('produtos', produto.toMap());
    return produto.copyWith(id: id);
  }

  // READ ALL
  Future<List<Produto>> listar() async {
    final db = await database;
    final rows = await db.query('produtos', orderBy: 'nome ASC');
    return rows.map(Produto.fromMap).toList();
  }

  // READ ONE
  Future<Produto?> buscarPorId(int id) async {
    final db = await database;
    final rows = await db.query('produtos', where: 'id = ?', whereArgs: [id]);
    if (rows.isEmpty) return null;
    return Produto.fromMap(rows.first);
  }

  // UPDATE
  Future<int> atualizar(Produto produto) async {
    final db = await database;
    return db.update(
      'produtos',
      produto.toMap(),
      where: 'id = ?',
      whereArgs: [produto.id],
    );
  }

  // DELETE
  Future<int> excluir(int id) async {
    final db = await database;
    return db.delete('produtos', where: 'id = ?', whereArgs: [id]);
  }
}
