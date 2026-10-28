import 'package:drift/drift.dart';

import '../domain/enums.dart';
import 'banco.dart';

/// Configurações padrão (chave → valor).
const configuracoesPadrao = <String, String>{
  'tema': 'dark',
  // Crédito seguro vale para a fatura do mês: parcelas futuras só informam.
  'modo_parcelados': 'parcela',
  'descontar_fixos': 'true',
  'comportamento_estouro': 'confirmar',
  'ocultar_valores': 'false',
  'bloqueio_minutos': '2',
  'biometria': 'false',
  'notificacoes': 'false',
  'notificacoes_dias': '1',
};

class _Seed {
  const _Seed(this.nome, this.icone, this.cor, [this.filhas = const []]);
  final String nome;
  final String icone;
  final int cor;
  final List<_Seed> filhas;
}

const _gastos = <_Seed>[
  _Seed('Moradia', 'home', 0xFF0F766E),
  _Seed('Alimentação', 'restaurant', 0xFFF59E0B, [
    _Seed('Mercado', 'cart', 0xFFF59E0B),
    _Seed('Delivery', 'delivery', 0xFFF59E0B),
    _Seed('Restaurante', 'restaurant', 0xFFF59E0B),
  ]),
  _Seed('Transporte/Carro', 'car', 0xFF3B82F6, [
    _Seed('Combustível', 'fuel', 0xFF3B82F6),
    _Seed('Manutenção', 'wrench', 0xFF3B82F6),
    _Seed('Peças', 'wrench', 0xFF3B82F6),
  ]),
  _Seed('Saúde', 'health', 0xFFEF4444),
  _Seed('Lazer', 'leisure', 0xFF8B5CF6),
  _Seed('Assinaturas', 'subscriptions', 0xFFEC4899),
  _Seed('Educação', 'school', 0xFF06B6D4),
  _Seed('Compras', 'shopping', 0xFF14B8A6),
  _Seed('Contas', 'bills', 0xFF64748B, [
    _Seed('Luz', 'bolt', 0xFF64748B),
    _Seed('Água', 'water', 0xFF64748B),
    _Seed('Internet', 'wifi', 0xFF64748B),
    _Seed('Celular', 'phone', 0xFF64748B),
  ]),
  _Seed('Outros', 'category', 0xFF94A3B8),
];

const _ganhos = <_Seed>[
  _Seed('Salário', 'salary', 0xFF16A34A),
  _Seed('Extra', 'extra', 0xFF22C55E),
  _Seed('Rendimentos', 'investments', 0xFF10B981),
  _Seed('Outros', 'category', 0xFF94A3B8),
];

/// Cria categorias padrão (apenas estrutura, sem dado pessoal) e configurações.
Future<void> semearBanco(AppDatabase db) async {
  await db.batch((b) {
    b.insertAll(
      db.configuracoes,
      [
        for (final e in configuracoesPadrao.entries)
          ConfiguracoesCompanion.insert(chave: e.key, valor: e.value),
      ],
      mode: InsertMode.insertOrIgnore,
    );
  });

  Future<void> inserir(List<_Seed> lista, TipoCategoria tipo) async {
    var ordem = 0;
    for (final pai in lista) {
      final paiId = await db.into(db.categorias).insert(
            CategoriasCompanion.insert(
              nome: pai.nome,
              tipo: tipo,
              icone: Value(pai.icone),
              cor: Value(pai.cor),
              ordem: Value(ordem++),
            ),
          );
      var ordemFilha = 0;
      for (final f in pai.filhas) {
        await db.into(db.categorias).insert(
              CategoriasCompanion.insert(
                nome: f.nome,
                tipo: tipo,
                icone: Value(f.icone),
                cor: Value(f.cor),
                categoriaPaiId: Value(paiId),
                ordem: Value(ordemFilha++),
              ),
            );
      }
    }
  }

  await inserir(_gastos, TipoCategoria.gasto);
  await inserir(_ganhos, TipoCategoria.ganho);
}
