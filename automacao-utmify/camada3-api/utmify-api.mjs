#!/usr/bin/env node
// utmify-api.mjs — cliente sem navegador para a UTMify.
//
// ⚠️ ESQUELETO. Os pontos marcados PREENCHER só podem ser fechados depois da
// captura descrita em CAPTURA.md. Rodar antes disso sai com erro explícito —
// de propósito: melhor falhar alto do que fingir que executou.
//
// uso:
//   node utmify-api.mjs status --nome "prosperidade"
//   node utmify-api.mjs pausar --campanha <id>
//   node utmify-api.mjs ativar --anuncio <id>
//   node utmify-api.mjs orcamento --campanha <id> --valor 300

import { execFileSync } from 'node:child_process';
import { readFileSync } from 'node:fs';
import { homedir } from 'node:os';

const DASHBOARD = '669065844d9e4e3220837eec';
const BASE = 'https://app.utmify.com.br'; // PREENCHER: host real da API (pode ser api.utmify.com.br)

function token() {
  try {
    return execFileSync('security',
      ['find-generic-password', '-a', process.env.USER, '-s', 'utmify-token', '-w'],
      { encoding: 'utf8' }).trim();
  } catch { /* cai pro .env */ }
  try {
    const env = readFileSync(`${homedir()}/.config/utmify/.env`, 'utf8');
    const m = env.match(/^UTMIFY_TOKEN=(.+)$/m);
    if (m) return m[1].trim();
  } catch { /* nada */ }
  throw new Error(
    'Sem credencial. Guarde no Keychain (security add-generic-password ' +
    '-a "$USER" -s utmify-token -w \'<TOKEN>\') ou em ~/.config/utmify/.env (chmod 600).');
}

const PENDENTE = (o) => {
  throw new Error(
    `Camada 3 ainda não capturada: não sei o endpoint de "${o}".\n` +
    'Rode o protocolo de camada3-api/CAPTURA.md no Chrome e preencha este arquivo.');
};

async function req(metodo, caminho, corpo) {
  const r = await fetch(`${BASE}${caminho}`, {
    method: metodo,
    headers: {
      // PREENCHER conforme a captura: Bearer? Cookie? x-workspace-id?
      'authorization': `Bearer ${token()}`,
      'content-type': 'application/json',
    },
    body: corpo ? JSON.stringify(corpo) : undefined,
  });
  const txt = await r.text();
  if (!r.ok) throw new Error(`HTTP ${r.status} em ${caminho}: ${txt.slice(0, 400)}`);
  try { return JSON.parse(txt); } catch { return txt; }
}

// A UTMify mente no toast da UI. Presuma que mente na API também: releia.
async function confirmar(tipo, id, esperado) {
  const atual = await status(tipo, id);
  if (atual !== esperado) {
    throw new Error(`NÃO CONFIRMADO: ${tipo} ${id} continua "${atual}", esperava "${esperado}".`);
  }
  return true;
}

async function status(_tipo, _id) { return PENDENTE('ler status'); }
async function pausar(tipo, id)   { PENDENTE('pausar');   await req('PATCH', ``, {}); await confirmar(tipo, id, 'PAUSED'); }
async function ativar(tipo, id)   { PENDENTE('ativar');   await req('PATCH', ``, {}); await confirmar(tipo, id, 'ACTIVE'); }
async function orcamento(id, v)   { PENDENTE('orçamento'); await req('PATCH', ``, { budget: v }); }

const [, , cmd, ...rest] = process.argv;
const arg = (n) => { const i = rest.indexOf(`--${n}`); return i >= 0 ? rest[i + 1] : undefined; };

try {
  switch (cmd) {
    case 'status':    console.log(await status('campanha', arg('campanha'))); break;
    case 'pausar':    await pausar(arg('anuncio') ? 'anuncio' : 'campanha', arg('anuncio') || arg('campanha')); console.log('pausado e confirmado'); break;
    case 'ativar':    await ativar(arg('anuncio') ? 'anuncio' : 'campanha', arg('anuncio') || arg('campanha')); console.log('ativado e confirmado'); break;
    case 'orcamento': await orcamento(arg('campanha'), Number(arg('valor'))); console.log('orçamento publicado'); break;
    default: console.log(`comandos: status | pausar | ativar | orcamento  (dashboard ${DASHBOARD})`);
  }
} catch (e) {
  console.error('❌', e.message);
  process.exit(1);
}
