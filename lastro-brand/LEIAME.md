# Lastro — identidade visual

Símbolo: um **"L" sólido** que funciona como base, com um **bloco turquesa** apoiado sobre ela. O bloco é o dinheiro já reservado em conta, sustentado pela base: a ideia de "lastro".

## Cores

| Papel | Hex |
|---|---|
| Primária (verde-petróleo) | `#0F766E` |
| Primária escura (gradiente do ícone) | `#0A4F4A` |
| Destaque no fundo escuro | `#5EEAD4` |
| Destaque no fundo claro | `#14B8A6` |
| Texto escuro / fundo escuro | `#0B1215` |
| Fundo claro | `#F6F8F8` |

Fonte do logotipo: **Inter SemiBold** (já convertida em curvas nos SVGs, não precisa instalar).

## Pastas

- `svg/` — originais vetoriais: ícone do app (quadrado e redondo), símbolo (colorido, branco, monocromático), logo horizontal e vertical (fundo claro e escuro) e as camadas do ícone adaptativo.
- `android/app/src/main/res/` — **pronto para copiar por cima** da pasta `android/app/src/main/res/` do projeto Flutter:
  - `mipmap-*/ic_launcher.png` e `ic_launcher_round.png` (48 a 192 px)
  - `mipmap-*/ic_launcher_foreground|background|monochrome.png` (camadas do ícone adaptativo, 108 a 432 px)
  - `mipmap-anydpi-v26/` — XML do ícone adaptativo, incluindo o ícone **temático do Android 13+** (monochrome)
  - `drawable-*/ic_notificacao.png` — silhueta branca para notificações (V2)
- `flutter/assets/branding/` — para colocar em `assets/branding/` do projeto: logos SVG para usar no app, símbolo em PNG @1x/@2x/@3x, ícone 1024, camadas do adaptativo em 1024 e imagens de splash.
- `outros/` — ícone 512 para a Play Store, ícone 1024, logos em PNG grande e feature graphic 1024×500.
- `previa.png` — visão geral.

## Como aplicar no projeto Flutter

**Opção A — copiar direto (mais simples):** copie a pasta `android/` deste pacote por cima da raiz do projeto, aceitando substituir os `ic_launcher`. Pronto.

**Opção B — via `flutter_launcher_icons`** (regera tudo a partir das imagens 1024), no `pubspec.yaml`:

```yaml
dev_dependencies:
  flutter_launcher_icons: ^0.14.0
  flutter_native_splash: ^2.4.0

flutter_launcher_icons:
  android: true
  ios: false
  image_path: assets/branding/icone-1024.png
  adaptive_icon_background: "#0F766E"
  adaptive_icon_foreground: assets/branding/adaptive-foreground-1024.png
  adaptive_icon_monochrome: assets/branding/adaptive-monochrome-1024.png

flutter_native_splash:
  color: "#0F766E"
  image: assets/branding/splash.png
  android_12:
    color: "#0F766E"
    image: assets/branding/splash-android12.png
```

Depois: `dart run flutter_launcher_icons` e `dart run flutter_native_splash:create`.

**Logos dentro do app:** para usar os SVGs em telas (login, "sobre"), adicione o pacote `flutter_svg` e declare `assets/branding/` no `pubspec.yaml`. Como esses pacotes não estão na lista do `CLAUDE.md`, avise o Claude Code que eles estão liberados.
