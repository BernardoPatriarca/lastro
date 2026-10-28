import '../domain/competencia.dart';
import '../domain/compromissos.dart';
import 'banco.dart';

/// Ocorrências previstas de um [Compromisso] até [ate], pelas regras do domínio
/// (não grava nada). Usado na geração mensal e na projeção de 12 meses.
List<OcorrenciaPrevista> ocorrenciasDe(Compromisso c, Competencia ate) =>
    gerarOcorrencias(
      tipo: c.tipo,
      valor: c.valor,
      diaVencimento: c.diaVencimento,
      dataInicio: c.dataInicio,
      numeroParcelas: c.numeroParcelas,
      ate: ate,
    );
