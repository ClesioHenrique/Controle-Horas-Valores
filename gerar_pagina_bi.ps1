# Gera a pagina exclusiva "Consulta_RDC.html" (so a Consulta por RDC / BI) a partir do Relatorio_Horas_Valores.html.
# Todos os dados das outras abas sao esvaziados (nao ficam no arquivo publicado). Rode de novo sempre que atualizar o relatorio:
#   powershell -File gerar_pagina_bi.ps1
$d = Split-Path -Parent $MyInvocation.MyCommand.Path
$enc = New-Object Text.UTF8Encoding($false)
$t = [IO.File]::ReadAllText("$d\Relatorio_Horas_Valores.html", $enc)
$names = 'RAW_EXTRATO','RAW_PENDENCIAS','RAW_FISCAL_PENDENTE','RAW_FISCAL_PENDENTE_DETAIL','RAW_MEDIDO_FR','RAW_MEDIDO_FR_DETAIL','RAW_FIA_MEDIDO','RAW_RATEIO_MEDIDO','RAW_FIA_MEDIDO_DETAIL','RAW_RATEIO_MEDIDO_DETAIL','RAW_FIA_EXTRATO','RAW_RATEIO_EXTRATO','RAW_PEND_APROVACAO_DETAIL','RAW_FRS_EMITIDAS','RAW_RDC_NAO_APROVADA','RAW_RDC_DETAIL','RAW_RDC_MOBILE_PENDENTE','RAW_ARIBA','RAW_EVOLUCAO','RAW_UTS','RAW_PEND_FISCAL','RAW_FISCAL_OUTROS','RAW_FIARAT_DETAIL'
foreach ($n in $names) {
  $re = [regex]("(?:const|let)\s+" + $n + "\s*=\s*\[[\s\S]*?\];")
  $m = $re.Match($t)
  if (-not $m.Success) { throw "nao achei $n" }
  $t = $t.Substring(0, $m.Index) + "let $n = [];" + $t.Substring($m.Index + $m.Length)
}
function Rep($s, $a, $b) { $i = $s.IndexOf($a); if ($i -lt 0) { throw "marca nao encontrada: $a" }; return $s.Substring(0, $i) + $b + $s.Substring($i + $a.Length) }
# pagina sempre no modo "so BI"
$t = Rep $t "if (!/[?&]vista=rdc\b/i.test(location.search) && !/^#vista-rdc/i.test(location.hash)) return;" "/* pagina exclusiva da BI */"
# sem Supabase (nao puxa os dados das outras abas)
$t = Rep $t "var supa = (window.supabase && window.supabase.createClient) ? window.supabase.createClient(SUPABASE_URL, SUPABASE_ANON_KEY) : null;" "var supa = null;"
$t = Rep $t "<title>Relatorio Gerencial - Controle de Horas x Valores</title>" "<title>Consulta por RDC (BI)</title>"
$t = [regex]::Replace($t, '(<div class="confronto-banner-title">)[^<]*(</div>)', '$1Consulta por RDC (BI)$2', 'None')
[IO.File]::WriteAllText("$d\Consulta_RDC.html", $t, $enc)
"ok " + (Get-Item "$d\Consulta_RDC.html").Length
