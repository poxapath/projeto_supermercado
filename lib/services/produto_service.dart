import '../models/produto.dart';
import '../repositories/produto_local_repository.dart';
import '../repositories/produto_api_repository.dart';

/// Camada de serviço — orquestra o SQLite local e a API remota.
/// 
/// Estratégia: operações acontecem primeiro localmente (offline-first),
/// depois são sincronizadas com a API quando possível.
class ProdutoService {
  final ProdutoLocalRepository _local;
  final ProdutoApiRepository _api;

  ProdutoService({
    ProdutoLocalRepository? local,
    ProdutoApiRepository? api,
  })  : _local = local ?? ProdutoLocalRepository(),
        _api = api ?? ProdutoApiRepository();

  // ── Listar ─────────────────────────────────────────────────────────────────

  Future<List<Produto>> listar() async {
    try {
      // Tenta buscar da API e atualiza o cache local
      final remotos = await _api.listar();
      // Salva remotos no SQLite como cache (simplificado)
      return remotos;
    } catch (_) {
      // Se não tiver internet, usa o SQLite local
      return _local.listar();
    }
  }

  Future<List<Produto>> listarLocal() => _local.listar();

  Future<List<Produto>> listarRemoto() => _api.listar();

  // ── Criar ──────────────────────────────────────────────────────────────────

  Future<Produto> criar(Produto produto) async {
    // Salva localmente primeiro
    final localSalvo = await _local.inserir(produto);

    try {
      // Sincroniza com a API
      final remotoCriado = await _api.criar(produto);
      return remotoCriado;
    } catch (_) {
      // Sem internet: retorna o salvo localmente
      return localSalvo;
    }
  }

  // ── Atualizar ──────────────────────────────────────────────────────────────

  Future<Produto> atualizar(Produto produto) async {
    await _local.atualizar(produto);

    try {
      return await _api.atualizar(produto);
    } catch (_) {
      return produto;
    }
  }

  // ── Excluir ────────────────────────────────────────────────────────────────

  Future<void> excluir(int id) async {
    await _local.excluir(id);

    try {
      await _api.excluir(id);
    } catch (_) {
      // Silencia erro de rede; produto já removido localmente
    }
  }

  // ── Helpers ────────────────────────────────────────────────────────────────

  Future<bool> checarConexaoApi() async {
    try {
      await _api.listar();
      return true;
    } catch (_) {
      return false;
    }
  }
}
