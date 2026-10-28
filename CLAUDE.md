# App de Finanças Pessoal — Especificação para o Claude Code

## Contexto

App de finanças pessoais para Android, de uso exclusivo de uma pessoa (o dono do projeto). Não há servidor, não há contas de usuário e não há sincronização: **tudo fica num banco SQLite local no celular**.

Objetivo do dono: separar o que **ganha**, **gasta** e **investe**, enxergar para onde vai o dinheiro e, principalmente, **nunca gastar no cartão de crédito mais do que já tem em conta** (regra "Crédito seguro", seção 5.1 — é o coração do app).

O dono é desenvolvedor Full Stack (Java/Angular) e está começando em Flutter/Dart: escreva código claro, bem organizado e com comentários onde a regra de negócio não for óbvia.

Idioma: interface, nomes de domínio, mensagens e comentários em **português do Brasil**. Formato de moeda `R$ 1.234,56`, datas `dd/MM/yyyy`, locale `pt_BR`.

---

## 0. Identidade, tema e branding

### Identidade
- **Nome do app:** Lastro
- **Package/applicationId:** `com.bernardopatriarca.lastro`
- **Descrição:** App mobile de finanças pessoais, offline e de uso individual. Separa ganhos, gastos e investimentos, controla faturas e parcelas do cartão, importa extratos OFX/CSV e calcula em tempo real quanto ainda dá para gastar no crédito sem passar do saldo em conta.

### Tema (Material 3; escuro como padrão, claro e automático disponíveis)
- Primária `#0F766E` · Primária escura `#0A4F4A`
- Secundária `#14B8A6` (claro) / `#5EEAD4` (escuro)
- Alerta `#F59E0B` · Positivo `#16A34A` · Negativo `#DC2626`
- Fundo escuro `#0B1215` · Fundo claro `#F6F8F8`
- Fonte **Inter**, com números tabulares (`FontFeature.tabularFigures`) em todos os valores em R$ (use o widget `ValorMonetario`).
- Cards arredondados, bastante respiro; o card **"Pode gastar no crédito"** fica sempre em destaque no Início.
- Implementação: `lib/core/theme/` (`PaletaLastro`, `CoresLastro` como `ThemeExtension`, `TemaLastro`). No tema escuro, positivo/negativo/alerta usam tons um pouco mais claros que a paleta, só para manter contraste de texto; no claro o alerta usa âmbar escuro pelo mesmo motivo.

### Identidade visual (pasta `lastro-brand/`, ver `lastro-brand/LEIAME.md`)
- Os originais ficam em `lastro-brand/` (pode continuar no repositório como fonte).
- Ícone do app: `lastro-brand/android/app/src/main/res/` copiado por cima de `android/app/src/main/res/` (inclui ícone adaptativo e temático do Android 13+).
- `lastro-brand/flutter/assets/branding/` → `assets/branding/`, declarado no `pubspec.yaml`.
- Splash: `flutter_native_splash` (configuração no `pubspec.yaml`), usando `assets/branding/splash*.png`. Para regerar: `dart run flutter_native_splash:create`.
- Logo SVG (`flutter_svg`) na tela de login: versão `claro`/`escuro` conforme o tema.
- Inter embutida em `assets/fonts/` (4 pesos + licença OFL), para funcionar offline.

### Pacotes liberados além da lista da seção 1
`flutter_svg`, `google_fonts` (preferir Inter embutida em `assets/fonts`, que funciona offline), `flutter_native_splash` (dev) e `flutter_launcher_icons` (dev).

### Regras extras
- A pasta `dados/` (extratos reais) está no `.gitignore` desde o primeiro commit. **Não ler nem usar esses arquivos até a Etapa 9**; o dono só os fornece quando o app estiver completamente pronto.

---

## 1. Stack

| Item | Escolha |
|---|---|
| Framework | Flutter (estável mais recente), apenas Android por enquanto |
| Banco | SQLite via **drift** (com migrations versionadas) |
| Estado | **Riverpod** (`flutter_riverpod`, preferir providers simples; codegen opcional) |
| Navegação | **go_router** |
| Gráficos | **fl_chart** |
| Autenticação local | `local_auth` (biometria) + `flutter_secure_storage` (hash e salt da senha) |
| Hash de senha | `cryptography` (PBKDF2 ou Argon2id com salt aleatório) |
| Arquivos | `file_picker`, `path_provider`, `share_plus` (exportar backup) |
| Importação | parser próprio de **OFX**; `csv` para CSV; PDF numa etapa posterior (ver seção 7) |
| Formatação | `intl` |
| Notificações | `flutter_local_notifications` (vencimentos, a partir da V2) |

Antes de adicionar qualquer pacote fora desta lista, explique o motivo e pergunte.

---

## 2. Regras gerais de implementação

- **Dinheiro sempre em centavos (`int`)**. Nunca usar `double` para valores. Converter só na exibição.
- Datas armazenadas como data local (sem hora quando não for necessária). "Competência" de um mês = `ano-mês`.
- Arquitetura em camadas, por funcionalidade:
  ```
  lib/
    core/        (tema, formatadores, utilitários, router)
    data/        (drift: tabelas, DAOs, migrations)
    domain/      (regras de negócio puras, sem Flutter: cálculo de saldo, faturas, crédito seguro, parcelas)
    features/    (uma pasta por tela/funcionalidade: ui + providers)
  ```
- **Regras de negócio ficam em `domain/` e têm testes unitários** (saldo, fatura, crédito seguro, geração de parcelas, importação, deduplicação).
- Tema Material 3, claro/escuro/automático, visual limpo e moderno. Valores positivos em verde, negativos em vermelho, sempre acompanhados de sinal ou texto (não depender só da cor).
- Toda tela deve ter estado vazio amigável ("Nenhum lançamento neste mês — toque em + para adicionar").
- Exclusões pedem confirmação. Edição de lançamento parcelado pergunta: "só esta parcela" ou "esta e as próximas".

### Privacidade dos dados reais
- Os extratos reais do dono ficam na pasta `dados/` na raiz do projeto. **Adicione `dados/` ao `.gitignore` antes do primeiro commit.**
- **Nunca** copiar dados reais do extrato para o código-fonte, seeds, testes ou fixtures. Para testes, crie arquivos OFX/CSV fictícios em `test/fixtures/`.
- Os dados reais entram no app **somente pela tela de importação**.

---

## 3. Modelo de dados (drift)

Sugestão inicial — pode ajustar nomes e tipos, mas mantenha os conceitos.

- **contas**: id, nome, tipo (`corrente`, `poupanca`, `carteira`), saldo_inicial (centavos), data_saldo_inicial, considerar_no_credito_seguro (bool, padrão true), ativa.
- **cartoes**: id, nome, limite (centavos), dia_fechamento, dia_vencimento, conta_pagamento_id, cor, ativo.
- **faturas**: id, cartao_id, competencia (ano-mês), data_fechamento, data_vencimento, status (`aberta`, `fechada`, `paga`), data_pagamento, lancamento_pagamento_id.
- **categorias**: id, nome, icone, cor, tipo (`gasto`, `ganho`), categoria_pai_id (subcategoria), ordem, ativa.
- **lancamentos**: id, tipo (`gasto`, `ganho`, `transferencia`, `aporte`, `resgate`, `pagamento_fatura`, `ajuste_saldo`), valor (centavos, sempre positivo; o tipo define o sentido), data, descricao, categoria_id, forma_pagamento (`debito`, `pix`, `dinheiro`, `boleto`, `credito`), conta_id, conta_destino_id (transferências), cartao_id, fatura_id, compra_parcelada_id, parcela_numero, ocorrencia_compromisso_id, investimento_id, origem (`manual`, `importado`), chave_importacao (para deduplicar), criado_em, atualizado_em.
- **compras_parceladas** (cartão): id, cartao_id, descricao, categoria_id, valor_total, numero_parcelas, data_compra. Gera um lançamento por parcela, cada um ligado à fatura correta.
- **compromissos** (gastos fixos fora do cartão): id, descricao, categoria_id, forma_pagamento, conta_id, valor, dia_vencimento, data_inicio, tipo (`recorrente` = sem fim, `parcelado` = com fim), numero_parcelas (nulo se recorrente), ativo.
- **ocorrencias_compromisso**: id, compromisso_id, competencia, numero_parcela, valor, data_vencimento, status (`pendente`, `paga`), lancamento_id (preenchido ao pagar).
- **receitas_recorrentes**: id, descricao, categoria_id, conta_id, valor_previsto, dia_previsto, ativa. Gera receitas "previstas" para confirmar.
- **investimentos**: id, nome, tipo (`reserva`, `cdb`, `tesouro`, `acoes`, `fiis`, `cripto`, `outro`), ativo.
- **movimentos_investimento**: id, investimento_id, tipo (`aporte`, `resgate`, `atualizacao_saldo`), valor, data, lancamento_id.
- **metas**: id, nome, valor_alvo, prazo, investimento_id (opcional), ativa.
- **orcamentos**: id, categoria_id, competencia, limite.
- **regras_categorizacao**: id, padrao (texto, comparação sem acento e sem diferenciar maiúsculas), categoria_id, prioridade.
- **configuracoes**: chave/valor (modo do crédito seguro, comportamento ao estourar, tema, ocultar valores, tempo de bloqueio etc.).

Seed inicial (apenas estrutura, sem dados pessoais): categorias padrão — Moradia, Alimentação (Mercado, Delivery, Restaurante), Transporte/Carro (Combustível, Manutenção, Peças), Saúde, Lazer, Assinaturas, Educação, Compras, Contas (Luz, Água, Internet, Celular), Outros; e de ganho — Salário, Extra, Rendimentos, Outros.

---

## 4. Telas

Navegação: barra inferior com **Início · Lançamentos · Cartões · Investimentos · Mais**, e um botão flutuante **"+"** (lançamento rápido) acessível nas abas principais.

### 4.1 Login
- Primeira abertura: o dono define a senha (com confirmação) e escolhe se ativa biometria. Salvar apenas **hash + salt** no `flutter_secure_storage`. **Nada de senha fixa no código.**
- Aberturas seguintes: biometria (se ativa) ou senha.
- Bloqueio automático após X minutos em segundo plano (configurável, padrão 2 min).
- Após 5 tentativas erradas, espera de 30 s.

### 4.2 Início (Dashboard)
- Seletor de mês no topo.
- **Card de destaque "Pode gastar no crédito"** (seção 5.1), com barra do quanto da conta já está comprometido e aviso visual quando negativo.
- Cards: Ganhos, Gastos, Investido, Saldo do mês; saldo atual total das contas.
- Taxa de poupança do mês (investido ÷ ganhos).
- Card **"Contas do mês"**: compromissos e faturas que vencem no mês — pago × falta pagar, com atalho para pagar.
- Gráfico de pizza de gastos por categoria.
- Top 5 categorias com barra de orçamento (V2).
- 5 maiores gastos do mês.
- Projeção de gasto no fim do mês no ritmo atual (V2).
- Progresso das metas (V2).
- Lista de alertas (V2/V3).

### 4.3 Lançamento rápido ("+")
- Abas: **Gasto · Ganho · Transferência/Aporte**.
- Teclado numérico já aberto no campo valor; categorias mais usadas primeiro, como chips.
- Campos: valor, categoria, forma de pagamento, conta, data (hoje), descrição opcional.
- Se **crédito**: cartão + número de parcelas. Mostrar em tempo real o impacto no crédito seguro: "Depois dessa compra sobra R$ X" (vermelho se estourar) e aplicar o comportamento configurado (seção 5.1).
- Opção **"Gasto fixo"**: recorrente sem fim **ou** parcelado (valor da parcela, nº de parcelas, dia de vencimento, data da primeira) → cria um compromisso.
- Opção **"Repetir todo mês"** para ganho → cria receita recorrente.

### 4.4 Lançamentos
- Lista agrupada por dia com total diário, filtros (período, tipo, categoria, forma, conta, cartão) e busca por descrição.
- Tocar abre a edição; arrastar exclui (com confirmação).
- Seção no topo: **"Pendentes"** — receitas previstas a confirmar e ocorrências de compromissos a pagar, com ação de um toque.

### 4.5 Cartões
- Lista: limite, usado, disponível (do banco) e **fatura atual**.
- Detalhe: fatura atual com lançamentos e parcelas; navegação para faturas futuras (valor já comprometido em cada uma); datas de fechamento e vencimento; botão **"Pagar fatura"** (gera lançamento `pagamento_fatura` saindo da conta de pagamento e marca a fatura como paga).
- Cadastro/edição de cartão.

### 4.6 Investimentos (V2)
- Patrimônio total + gráfico de evolução mensal.
- Lista por tipo com saldo atual (saldo = último `atualizacao_saldo` ajustado por aportes/resgates posteriores).
- Detalhe: histórico de movimentos, botões Aporte, Resgate e **Atualizar saldo**.
- Metas: nome, valor-alvo, prazo, investimento vinculado; barra de progresso; aporte mensal necessário = (alvo − atual) ÷ meses restantes; indicação "no ritmo" ou "atrasada".

### 4.7 Mais
- **Compromissos**: todos os fixos e parcelados ativos, com progresso (ex.: 3/10), valor restante, data de término; e gráfico/lista do **total comprometido por mês nos próximos 12 meses** (parcelas de cartão + compromissos).
- **Relatórios** (V3): evolução mensal de ganhos × gastos × investimentos (6–12 meses), comparativo por categoria com o mês anterior, média mensal por categoria, fixos × variáveis.
- **Orçamento** (V2): limite mensal por categoria, barras verde (<80%), amarelo (80–100%), vermelho (>100%); copiar do mês anterior.
- **Categorias**: CRUD de categorias/subcategorias e de **regras de categorização**.
- **Contas**: CRUD de contas, saldo atual calculado, transferência entre contas e botão **"Ajustar saldo"** (o dono informa o saldo real do banco; o app cria um lançamento `ajuste_saldo` com a diferença).
- **Importar extrato** (seção 7).
- **Configurações**: trocar senha, biometria, tempo de bloqueio, tema, **ocultar valores** (exibir `R$ •••`), configurações do crédito seguro, exportar/restaurar backup.

---

## 5. Regras de negócio

### 5.1 Crédito seguro (prioridade máxima)

Princípio: **toda compra no crédito precisa já ter o dinheiro em conta para pagá-la.** A fatura deve sempre ser paga com dinheiro que já existe, nunca com o salário que ainda vai entrar.

```
pode_gastar_no_credito =
    saldo atual das contas marcadas "considerar no crédito seguro"
  − compromisso no cartão (depende do modo, abaixo)
  − contas fixas pendentes (se "descontar contas fixas" estiver ligado)
```

- **Modo de parcelados** (configuração, padrão `rigido`):
  - `rigido`: compromisso no cartão = **todo o valor ainda não pago** em todos os cartões (faturas abertas, fechadas não pagas e todas as parcelas futuras).
  - `parcela`: compromisso no cartão = faturas abertas e fechadas não pagas (incluindo as parcelas que caem nelas). As parcelas futuras aparecem como informação separada ("Comprometido nas próximas faturas: R$ X").
- **Descontar contas fixas** (padrão `ligado`): subtrai as ocorrências de compromissos com status `pendente` e vencimento até o vencimento da próxima fatura.
- **Comportamento ao estourar** (padrão `confirmar`):
  - `avisar`: só mostra o aviso em vermelho;
  - `confirmar`: diálogo "Essa compra deixa a fatura R$ X acima do seu saldo. Você não terá dinheiro para pagá-la. Lançar mesmo assim?";
  - `bloquear`: impede o lançamento.
- Exemplo que **deve virar teste**: saldo R$ 700, fatura em aberto R$ 500, sem fixos → pode gastar R$ 200. Com um boleto pendente de R$ 250 e fixos ligados → R$ −50.
- O cálculo é uma função pura em `domain/`, recalculada sempre que algo muda (provider reativo sobre as queries do drift).

### 5.2 Saldo das contas
```
saldo = saldo_inicial
      + ganhos + resgates + transferências recebidas
      − gastos não-crédito (débito, pix, dinheiro, boleto)
      − pagamentos de fatura − aportes − transferências enviadas
      ± ajustes de saldo
```
Compras no crédito **não** mexem no saldo da conta; só o pagamento da fatura mexe.

### 5.3 Faturas
- Uma compra com data **antes** do dia de fechamento entra na fatura do ciclo atual; **a partir** do dia de fechamento, entra na fatura seguinte.
- Se o dia de vencimento for menor que o de fechamento, o vencimento cai no mês seguinte ao fechamento.
- Tratar meses curtos (ex.: fechamento dia 31 em fevereiro → último dia do mês).
- Faturas são criadas sob demanda quando uma compra/parcela precisa delas.
- Status muda para `fechada` automaticamente após a data de fechamento.

### 5.4 Parcelamento no cartão
- Dividir o total em centavos; a diferença de arredondamento vai na **primeira** parcela (ex.: R$ 100,00 em 3x → 33,34 + 33,33 + 33,33).
- Parcela N vai para a fatura N−1 ciclos após a da compra. Descrição: "Descrição (2/10)".

### 5.5 Compromissos (fixos fora do cartão)
- Ao abrir o app, gerar as ocorrências até o mês atual + 1 (e, para a projeção, calcular — sem necessariamente persistir — os próximos 12 meses).
- Parcelado encerra automaticamente após a última parcela.
- Pagar uma ocorrência cria o lançamento de gasto correspondente na conta escolhida.

### 5.6 Receitas recorrentes
- Geram uma receita "prevista" por mês; o dono confirma (podendo ajustar o valor), o que cria o lançamento real.

---

## 6. Backup
- **Exportar**: JSON com versão do schema e todas as tabelas → salvar/compartilhar via `share_plus`.
- **Restaurar**: validar versão, mostrar resumo (nº de lançamentos, período) e pedir confirmação antes de substituir tudo.
- Lembrete na tela de Configurações com a data do último backup.

---

## 7. Importação de extrato
- Formatos: **OFX** (prioritário) e **CSV** (com tela para mapear colunas: data, descrição, valor e, se houver, tipo; salvar o mapeamento por banco). **PDF**: só depois que OFX/CSV estiverem prontos; avaliar extração de texto e, se não for confiável, propor alternativa ao dono antes de implementar.
- Fluxo: escolher arquivo → escolher conta (ou cartão, se for fatura) → **tela de revisão** → confirmar.
- Tela de revisão:
  - cada transação com data, descrição, valor e **categoria sugerida** pelas regras de categorização;
  - edição de categoria por linha e seleção para ignorar linhas;
  - **duplicadas** marcadas e desmarcadas por padrão (chave de importação = FITID do OFX, ou hash de data + valor + descrição normalizada);
  - transações parecidas com uma **ocorrência de compromisso pendente** (mesmo valor, data em ±5 dias) sugerem "marcar parcela como paga" em vez de criar gasto novo.
- Ao corrigir a categoria de uma linha, oferecer: "Criar regra: descrições com 'XXXX' → Categoria".
- Após a primeira importação, oferecer "Ajustar saldo inicial" para bater com o saldo real do banco.

---

## 8. Etapas de entrega

Execute **uma etapa por vez**. Ao final de cada etapa:
1. rode `flutter analyze` (sem erros nem avisos) e `flutter test`;
2. faça um commit em português e descritivo;
3. **pare** e me apresente um resumo do que foi feito, como testar no celular (`flutter run`) e o que vem a seguir. Só avance quando eu pedir.

### V1 — base
- **Etapa 0**: criar o projeto Flutter, `.gitignore` (incluindo `dados/`), estrutura de pastas, tema, locale pt_BR, go_router com as abas (telas vazias), README com comandos.
- **Etapa 1**: banco drift completo (todas as tabelas da seção 3), migrations, seed de categorias, DAOs e testes do domínio de saldo.
- **Etapa 2**: login (senha com hash + biometria + bloqueio automático).
- **Etapa 3**: contas + lançamento rápido + lista de lançamentos (gasto, ganho, transferência, ajuste de saldo).
- **Etapa 4**: cartões, faturas, compras parceladas e pagamento de fatura (com testes das regras 5.3 e 5.4).
- **Etapa 5**: compromissos (recorrentes e parcelados), receitas recorrentes, pendentes e tela de Compromissos com projeção de 12 meses.
- **Etapa 6**: **crédito seguro** (regra 5.1 com testes), card no Início, impacto em tempo real no lançamento rápido e configurações.
- **Etapa 7**: Início versão simples (cards, contas do mês, pizza, maiores gastos).
- **Etapa 8**: categorias e regras de categorização.
- **Etapa 9**: importação OFX e CSV com tela de revisão e deduplicação.
- **Etapa 10**: backup/restauração, ocultar valores, configurações restantes e geração do APK (`flutter build apk --release`).

### V2
- Investimentos e metas, orçamento por categoria, dashboard completo (projeção, top categorias com orçamento, metas), notificações de vencimento de fatura e compromissos.

### V3
- Relatórios, alertas avançados no Início, importação de PDF, refinamentos de usabilidade.

---

## 10. Decisões de implementação (registradas durante a V1)

Escolhas que não estão óbvias no código ou que ajustam a sugestão da seção 3:

- **Datas** sem hora são gravadas como inteiro `aaaammdd` (conversor `ConversorData`); competências, como texto `aaaa-mm`. `criado_em`/`atualizado_em` usam `DateTime` normal.
- **Valor sempre positivo**, com uma exceção: em `ajuste_saldo` o sinal do `valor` define o sentido do ajuste.
- **`lancamentos.conta_id` é nulo nas compras no crédito** (pertencem a um cartão). Colunas extras: `receita_recorrente_id` (vínculo da receita confirmada). Tabela extra: `mapeamentos_csv` (mapeamento por banco).
- **Parcela de cartão**: cada parcela é um lançamento com data = data da compra + (N−1) meses (assim pesa no mês certo) e `fatura_id` calculado pelo ciclo (regras 5.3/5.4).
- **Fatura paga** não aceita editar/excluir suas compras; excluir o lançamento de pagamento reabre a fatura. Excluir o lançamento de uma conta fixa paga reabre a ocorrência.
- **Crédito seguro**: "futura" = fatura de ciclo posterior ao de hoje. Contas fixas pendentes entram até o **maior** vencimento da fatura atual entre os cartões (sem cartões, fim do mês). A checagem de estouro vale para **compra nova** no crédito.
- **Ocorrências de compromissos** só são geradas a partir do mês anterior ao atual (compromissos antigos não inundam a lista de pendentes).
- **Receitas recorrentes**: "pendente" vale para o mês atual; "Repetir todo mês" lança o ganho de agora e começa a recorrência no mês seguinte.
- **Importação**: chave de importação = `c<contaId>`/`k<cartaoId>` + FITID (ou data|valor|descrição normalizada), com `#2`, `#3`… para idênticas no mesmo arquivo. Em fatura de cartão, entradas (estornos, "pagamento recebido") começam desmarcadas e são ignoradas ao importar.
- **Backup**: JSON `{formato, versaoSchema, exportadoEm, tabelas}` com as linhas cruas do SQLite; restaurar é atômico (transação com FKs adiadas) e recusa versão mais nova. A senha (cofre seguro) nunca entra no backup.
- **Dados fictícios** (`lib/data/dados_ficticios.dart`) só aparecem em Configurações no modo debug, junto de "Apagar todos os dados".
- **Android**: `allowBackup=false` (dados financeiros fora do backup automático do Google), tema `AppCompat` e `FlutterFragmentActivity` por causa da biometria. Sem permissão de internet no app de release.
- **Riverpod 3 pausa streams sem ouvinte**: em testes use `container.listen` antes de `await read(provider.future)`; em código de serviço, leia do banco direto em vez de `ref.read` de `StreamProvider`.
- Diálogos com `TextEditingController` devem descartá-los com `descartarDepoisDoDialogo` (após a animação de saída).

### V2 e V3 (implementadas)

- **Investimentos**: saldo = último `atualizacao_saldo` ajustado por aportes/resgates posteriores (mesmo dia: ordem de criação). Aporte/resgate são **lançamentos** na conta + movimento do investimento (excluir/editar um acompanha o outro); "atualizar saldo" é só movimento. Meta sem investimento vinculado usa o patrimônio total.
- **Metas**: aporte mensal necessário = (alvo − atual) ÷ meses restantes (para cima; meses = dias ÷ 30 para cima, mínimo 1). "No ritmo" = média mensal de aportes líquidos dos últimos 3 meses ≥ necessário; senão "atrasada".
- **Orçamento**: limite por categoria/mês; o gasto de subcategorias conta também no pai. Faixas: verde < 80%, amarelo 80–100%, vermelho > 100%. "Copiar do mês anterior" nunca sobrescreve.
- **Alertas** (Início): crédito seguro negativo, contas/faturas atrasadas ou a vencer em até 3 dias, orçamento do mês atual, metas atrasadas e backup com mais de 30 dias.
- **Notificações**: desligadas por padrão; ao ligar pede a permissão (Android 13+). Aviso N dias antes (0–3) às 9h, até 45 dias à frente, no máximo 60 alarmes, **alarmes inexatos** (sem permissão de alarme exato). Agendadas por instante absoluto (UTC), sem depender do fuso do aparelho. O sincronizador reagenda quando faturas, contas ou configurações mudam.
- **Relatórios**: "fixo" = gasto que paga um compromisso ou é parcela de compra parcelada no cartão; o resto é variável. Média mensal divide sempre pelo nº de meses da janela.
- **Layout**: linhas de conta usam `LinhaConta` (não `ListTile` com trailing largo). O teste `telas_estreitas_test.dart` percorre todas as telas e formulários em 320 dp com fonte 1,3x e falha em qualquer overflow: rode-o ao mexer em layouts.
- **PDF (V3)**: não implementado de propósito. A seção 7 pede avaliar antes; extrair texto de PDF de banco é pouco confiável (cada banco tem um layout). Alternativas propostas ao dono: (1) pedir OFX/CSV ao banco, que o app já importa; (2) "colar texto" do extrato copiado do PDF, lido por regras de data e valor com a mesma tela de revisão.

---

## 9. Como trabalhar comigo
- Se algo nesta especificação for ambíguo ou parecer errado, **pergunte antes** de decidir sozinho.
- Prefira soluções simples e legíveis a abstrações sofisticadas.
- Não invente dados financeiros; para testar visualmente, crie um modo/seed de **dados fictícios** acionável só em debug.
- Teste no aparelho físico via USB (`flutter devices`, `flutter run`).
