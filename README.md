# Lastro

App Android de finanças pessoais, offline e de uso individual. Separa ganhos, gastos e investimentos, controla faturas e parcelas do cartão, importa extratos OFX/CSV e calcula quanto ainda dá para gastar no crédito sem passar do saldo em conta ("Crédito seguro").

Especificação completa: [CLAUDE.md](CLAUDE.md). Identidade visual: [lastro-brand/LEIAME.md](lastro-brand/LEIAME.md).

- Package: `com.bernardopatriarca.lastro`
- Stack: Flutter · Riverpod · go_router · drift (SQLite) · fl_chart · local_auth · flutter_secure_storage

## O que o app faz

- **Login** com senha (hash + salt) e biometria; bloqueio automático e espera de 30 s após 5 erros.
- **Contas, lançamentos e transferências**, ajuste de saldo, lançamento rápido com teclado numérico.
- **Cartões**: faturas por ciclo, compras à vista e parceladas, pagamento de fatura, limite usado/disponível.
- **Compromissos**: gastos fixos e parcelados, receitas recorrentes, pendentes de um toque e projeção de 12 meses.
- **Crédito seguro**: quanto ainda dá para gastar no crédito, com impacto em tempo real em cada compra.
- **Início**: totais do mês, taxa de poupança, contas do mês, gastos por categoria e maiores gastos.
- **Categorias e regras** de categorização; **importação** de OFX e CSV com revisão e deduplicação.
- **Backup e restauração** em JSON, ocultar valores, tema escuro/claro/automático.
- **Investimentos e metas**: patrimônio com evolução mensal, aportes, resgates e atualização de saldo; aporte mensal necessário por meta.
- **Orçamento por categoria** com barras verde/amarela/vermelha e cópia do mês anterior.
- **Início completo**: alertas, projeção do mês, top categorias com orçamento e progresso das metas.
- **Notificações** de vencimento de faturas e contas fixas (opcionais).
- **Relatórios**: evolução, comparativo com o mês anterior, média por categoria e fixos × variáveis.

## Pré-requisitos

- Flutter (canal stable) e Android SDK no `PATH` (`flutter doctor` sem erros em "Android toolchain")
- Celular Android com **Depuração USB** ligada

## Comandos

```bash
flutter pub get                                    # baixa dependências
flutter devices                                    # lista aparelhos conectados
flutter run                                        # roda no celular (debug)
flutter analyze                                    # análise estática (deve ficar sem avisos)
flutter test                                       # testes
dart run build_runner build                        # regera o código do drift (após mudar tabelas)
dart run flutter_native_splash:create              # regera o splash
flutter build apk --release                        # gera o APK (build/app/outputs/flutter-apk/app-release.apk)
flutter build apk --release --split-per-abi        # APKs menores, um por arquitetura (use o arm64-v8a)
```

Em `flutter run` (debug), **Mais › Configurações** tem "Carregar dados fictícios" e "Apagar todos os dados" para testar o app sem seus dados reais. Isso não existe no APK de release.

## Estrutura

```
lib/
  core/        tema, formatadores, widgets base, router
  data/        drift: tabelas, DAOs, serviços (escritas), providers reativos
  domain/      regras de negócio puras, com testes (saldo, fatura, parcelas,
               crédito seguro, compromissos, importação, backup...)
  features/    uma pasta por tela (ui + providers)
assets/
  branding/    logos e imagens da marca
  fonts/       Inter (embutida, funciona offline)
test/          testes; arquivos de extrato fictícios em test/fixtures/
```

## Privacidade

Os extratos reais ficam em `dados/`, ignorada pelo git. Nunca copie dados reais para código, seeds ou testes: eles entram só pela tela de importação. O backup não inclui a senha.
