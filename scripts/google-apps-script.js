/**
 * IM Digital · API Google Sheets
 * Cole esse código TODO em script.google.com (extensões da planilha)
 *
 * Endpoints suportados:
 *   GET  ?action=read&sheet=criativos
 *   POST { action: 'write', sheet: 'criativos', row: {...} }
 *   POST { action: 'update', sheet: 'criativos', id: 'xxx', updates: {...} }
 *   POST { action: 'delete', sheet: 'criativos', id: 'xxx' }
 */

const ALLOWED_SHEETS = ['criativos', 'campanhas', 'subidas', 'historico_dia', 'config'];

function doGet(e) {
  return handleRequest(e);
}

function doPost(e) {
  return handleRequest(e);
}

function handleRequest(e) {
  try {
    let params = {};

    // GET parameters
    if (e.parameter) {
      params = { ...e.parameter };
    }

    // POST body
    if (e.postData && e.postData.contents) {
      try {
        const body = JSON.parse(e.postData.contents);
        params = { ...params, ...body };
      } catch (err) {
        // Ignora se não for JSON válido
      }
    }

    const action = params.action || 'read';
    const sheetName = params.sheet;

    if (!ALLOWED_SHEETS.includes(sheetName)) {
      return jsonResponse({ error: 'Sheet inválida', allowed: ALLOWED_SHEETS }, 400);
    }

    switch (action) {
      case 'read':
        return jsonResponse(readSheet(sheetName));
      case 'write':
        return jsonResponse(writeRow(sheetName, params.row));
      case 'update':
        return jsonResponse(updateRow(sheetName, params.id, params.updates));
      case 'delete':
        return jsonResponse(deleteRow(sheetName, params.id));
      case 'bulk_write':
        return jsonResponse(bulkWrite(sheetName, params.rows));
      default:
        return jsonResponse({ error: 'Ação inválida' }, 400);
    }
  } catch (error) {
    return jsonResponse({
      error: error.toString(),
      stack: error.stack
    }, 500);
  }
}

/**
 * Lê todas as linhas de uma sheet, retorna array de objetos
 */
function readSheet(sheetName) {
  const ss = SpreadsheetApp.getActiveSpreadsheet();
  const sheet = ss.getSheetByName(sheetName);
  if (!sheet) return { data: [], error: 'Sheet não encontrada' };

  const data = sheet.getDataRange().getValues();
  if (data.length < 2) return { data: [] };

  const headers = data[0];
  const rows = data.slice(1).map((row, idx) => {
    const obj = { _row: idx + 2 }; // linha real na planilha
    headers.forEach((h, i) => {
      if (h) obj[h] = row[i];
    });
    return obj;
  });

  return { data: rows, total: rows.length };
}

/**
 * Adiciona uma nova linha
 */
function writeRow(sheetName, row) {
  if (!row || typeof row !== 'object') {
    return { error: 'row inválido' };
  }

  const ss = SpreadsheetApp.getActiveSpreadsheet();
  const sheet = ss.getSheetByName(sheetName);
  if (!sheet) return { error: 'Sheet não encontrada' };

  const headers = sheet.getRange(1, 1, 1, sheet.getLastColumn()).getValues()[0];

  // Gera ID se não tiver
  if (!row.id) {
    row.id = 'id_' + Date.now() + '_' + Math.random().toString(36).substr(2, 6);
  }

  // Auto-preenche atualizado_em se a coluna existir
  if (headers.includes('atualizado_em') && !row.atualizado_em) {
    row.atualizado_em = new Date().toISOString();
  }

  const newRow = headers.map(h => row[h] !== undefined ? row[h] : '');
  sheet.appendRow(newRow);

  return { success: true, id: row.id, row };
}

/**
 * Atualiza uma linha existente pelo ID
 */
function updateRow(sheetName, id, updates) {
  if (!id) return { error: 'id obrigatório' };
  if (!updates || typeof updates !== 'object') return { error: 'updates inválido' };

  const ss = SpreadsheetApp.getActiveSpreadsheet();
  const sheet = ss.getSheetByName(sheetName);
  if (!sheet) return { error: 'Sheet não encontrada' };

  const data = sheet.getDataRange().getValues();
  const headers = data[0];
  const idColIdx = headers.indexOf('id');
  if (idColIdx === -1) return { error: 'sheet não tem coluna id' };

  // Encontra a linha pelo ID
  let rowIdx = -1;
  for (let i = 1; i < data.length; i++) {
    if (String(data[i][idColIdx]) === String(id)) {
      rowIdx = i;
      break;
    }
  }
  if (rowIdx === -1) return { error: 'id não encontrado' };

  // Auto-atualiza atualizado_em
  if (headers.includes('atualizado_em')) {
    updates.atualizado_em = new Date().toISOString();
  }

  // Aplica updates
  Object.keys(updates).forEach(key => {
    const colIdx = headers.indexOf(key);
    if (colIdx !== -1) {
      sheet.getRange(rowIdx + 1, colIdx + 1).setValue(updates[key]);
    }
  });

  return { success: true, id, updates };
}

/**
 * Deleta uma linha pelo ID
 */
function deleteRow(sheetName, id) {
  if (!id) return { error: 'id obrigatório' };

  const ss = SpreadsheetApp.getActiveSpreadsheet();
  const sheet = ss.getSheetByName(sheetName);
  if (!sheet) return { error: 'Sheet não encontrada' };

  const data = sheet.getDataRange().getValues();
  const headers = data[0];
  const idColIdx = headers.indexOf('id');
  if (idColIdx === -1) return { error: 'sheet não tem coluna id' };

  for (let i = 1; i < data.length; i++) {
    if (String(data[i][idColIdx]) === String(id)) {
      sheet.deleteRow(i + 1);
      return { success: true, id };
    }
  }

  return { error: 'id não encontrado' };
}

/**
 * Escreve várias linhas de uma vez (importação em lote)
 */
function bulkWrite(sheetName, rows) {
  if (!Array.isArray(rows) || rows.length === 0) {
    return { error: 'rows deve ser array não-vazio' };
  }

  const ss = SpreadsheetApp.getActiveSpreadsheet();
  const sheet = ss.getSheetByName(sheetName);
  if (!sheet) return { error: 'Sheet não encontrada' };

  const headers = sheet.getRange(1, 1, 1, sheet.getLastColumn()).getValues()[0];
  const now = new Date().toISOString();

  const newRows = rows.map(row => {
    if (!row.id) {
      row.id = 'id_' + Date.now() + '_' + Math.random().toString(36).substr(2, 6);
    }
    if (headers.includes('atualizado_em') && !row.atualizado_em) {
      row.atualizado_em = now;
    }
    return headers.map(h => row[h] !== undefined ? row[h] : '');
  });

  sheet.getRange(sheet.getLastRow() + 1, 1, newRows.length, headers.length).setValues(newRows);

  return { success: true, written: newRows.length };
}

/**
 * Resposta JSON com CORS
 */
function jsonResponse(data, status) {
  status = status || 200;
  return ContentService
    .createTextOutput(JSON.stringify(data))
    .setMimeType(ContentService.MimeType.JSON);
}
