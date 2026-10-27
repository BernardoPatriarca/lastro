# Lastro

App Android de finanças pessoais, offline e de uso individual. Separa ganhos, gastos e investimentos, controla faturas e parcelas do cartão, importa extratos OFX/CSV e calcula quanto ainda dá para gastar no crédito sem passar do saldo em conta ("Crédito seguro").

Especificação completa: [CLAUDE.md](CLAUDE.md). Identidade visual: [lastro-brand/LEIAME.md](lastro-brand/LEIAME.md).

- Package: `com.bernardopatriarca.lastro`
- Stack: Flutter · Riverpod · go_router · (drift, fl_chart e demais a partir das próximas etapas)

## Pré-requisitos

- Flutter (canal stable) no `PATH`
- Android SDK (Android Studio ou só as command-line tools) e `flutter doctor` sem erros em "Android toolchain"
- Celular Android com **Depuração USB** ligada

## Comandos

```bash
flutter pub get                              # baixa dependências
flutter devices                              # lista aparelhos conectados
flutter run                                  # roda no celular (debug)
flutter analyze                              # análise estática (deve ficar sem avisos)
flutter test                                 # testes
dart run flutter_native_splash:create        # regera o splash (após mudar o pubspec)
flutter build apk --release                  # gera o APK (Etapa 10)
```

## Estrutura

```
lib/
  core/        tema, formatadores, widgets base, router
  data/        drift: tabelas, DAOs, migrations (Etapa 1)
  domain/      regras de negócio puras, com testes (Etapa 1 em diante)
  features/    uma pasta por tela (ui + providers)
assets/
  branding/    logos e imagens da marca
  fonts/       Inter (embutida, funciona offline)
test/          testes; fixtures fictícias em test/fixtures/
```

## Privacidade

Os extratos reais ficam em `dados/`, ignorada pelo git. Nunca copie dados reais para código, seeds ou testes: eles entram só pela tela de importação.
