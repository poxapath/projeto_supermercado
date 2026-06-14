import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/produto.dart';

/// Repositório remoto — consome a API publicada no Render.
class ProdutoApiRepository {
  // ⚠️  Troque pela URL real após subir no Render
  static const String _baseUrl = 'https://supermercado-api-mkqz.onrender.com';

  final http.Client _client;
  ProdutoApiRepository({http.Client? client}) : _client = client ?? http.Client();

  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };

  // CREATE
  Future<Produto> criar(Produto produto) async {
    final response = await _client.post(
      Uri.parse('$_baseUrl/produtos'),
      headers: _headers,
      body: jsonEncode(produto.toJson()),
    );
    _checkStatus(response);
    return Produto.fromJson(jsonDecode(response.body));
  }

  // READ ALL
  Future<List<Produto>> listar() async {
    final response = await _client.get(
      Uri.parse('$_baseUrl/produtos'),
      headers: _headers,
    );
    _checkStatus(response);
    final List<dynamic> data = jsonDecode(response.body);
    return data.map((e) => Produto.fromJson(e)).toList();
  }

  // READ ONE
  Future<Produto> buscarPorId(int id) async {
    final response = await _client.get(
      Uri.parse('$_baseUrl/produtos/$id'),
      headers: _headers,
    );
    _checkStatus(response);
    return Produto.fromJson(jsonDecode(response.body));
  }

  // UPDATE
  Future<Produto> atualizar(Produto produto) async {
    final response = await _client.put(
      Uri.parse('$_baseUrl/produtos/${produto.id}'),
      headers: _headers,
      body: jsonEncode(produto.toJson()),
    );
    _checkStatus(response);
    return Produto.fromJson(jsonDecode(response.body));
  }

  // DELETE
  Future<void> excluir(int id) async {
    final response = await _client.delete(
      Uri.parse('$_baseUrl/produtos/$id'),
      headers: _headers,
    );
    if (response.statusCode != 204) {
      _checkStatus(response);
    }
  }

  void _checkStatus(http.Response response) {
    if (response.statusCode >= 400) {
      throw Exception(
        'Erro ${response.statusCode}: ${response.body}',
      );
    }
  }
}
