/**
 * IM Digital · Sheets Client
 * Camada de comunicação com Google Sheets via Apps Script
 *
 * Como usar:
 *   const client = new SheetsClient(SHEETS_API_URL);
 *   await client.read('criativos');
 *   await client.write('criativos', { name: 'A1', status: 'ready' });
 *   await client.update('criativos', 'id_xxx', { status: 'running' });
 *   await client.delete('criativos', 'id_xxx');
 */

class SheetsClient {
  constructor(apiUrl) {
    if (!apiUrl) {
      console.warn('[SheetsClient] API URL não configurada - rodando em modo OFFLINE (localStorage)');
      this.offline = true;
    }
    this.apiUrl = apiUrl;
    this.cache = new Map();
    this.cacheTimestamps = new Map();
    this.cacheTTL = 30000; // 30s
  }

  /**
   * Lê dados de uma sheet (com cache de 30s)
   */
  async read(sheet, options = {}) {
    if (this.offline) return this._offlineRead(sheet);

    const cacheKey = sheet;
    if (!options.fresh && this._isCacheFresh(cacheKey)) {
      return this.cache.get(cacheKey);
    }

    try {
      const res = await fetch(`${this.apiUrl}?action=read&sheet=${sheet}`);
      const json = await res.json();
      if (json.error) throw new Error(json.error);

      this.cache.set(cacheKey, json.data || []);
      this.cacheTimestamps.set(cacheKey, Date.now());
      return json.data || [];
    } catch (err) {
      console.error(`[SheetsClient] erro ao ler ${sheet}:`, err);
      return this._offlineRead(sheet);
    }
  }

  /**
   * Escreve uma nova linha
   */
  async write(sheet, row) {
    if (this.offline) return this._offlineWrite(sheet, row);

    try {
      const res = await fetch(this.apiUrl, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ action: 'write', sheet, row })
      });
      const json = await res.json();
      this._invalidateCache(sheet);
      return json;
    } catch (err) {
      console.error(`[SheetsClient] erro ao escrever em ${sheet}:`, err);
      return this._offlineWrite(sheet, row);
    }
  }

  /**
   * Atualiza uma linha existente
   */
  async update(sheet, id, updates) {
    if (this.offline) return this._offlineUpdate(sheet, id, updates);

    try {
      const res = await fetch(this.apiUrl, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ action: 'update', sheet, id, updates })
      });
      const json = await res.json();
      this._invalidateCache(sheet);
      return json;
    } catch (err) {
      console.error(`[SheetsClient] erro ao atualizar ${id}:`, err);
      return this._offlineUpdate(sheet, id, updates);
    }
  }

  /**
   * Deleta uma linha
   */
  async delete(sheet, id) {
    if (this.offline) return this._offlineDelete(sheet, id);

    try {
      const res = await fetch(this.apiUrl, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ action: 'delete', sheet, id })
      });
      const json = await res.json();
      this._invalidateCache(sheet);
      return json;
    } catch (err) {
      console.error(`[SheetsClient] erro ao deletar:`, err);
      return this._offlineDelete(sheet, id);
    }
  }

  /**
   * Escreve várias linhas de uma vez
   */
  async bulkWrite(sheet, rows) {
    if (this.offline) {
      rows.forEach(r => this._offlineWrite(sheet, r));
      return { success: true, written: rows.length };
    }

    try {
      const res = await fetch(this.apiUrl, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ action: 'bulk_write', sheet, rows })
      });
      const json = await res.json();
      this._invalidateCache(sheet);
      return json;
    } catch (err) {
      console.error(`[SheetsClient] erro no bulk write:`, err);
      return { error: err.message };
    }
  }

  // ============ FALLBACK OFFLINE (localStorage) ============

  _offlineKey(sheet) { return `imdigital_sheet_${sheet}`; }

  _offlineRead(sheet) {
    const data = JSON.parse(localStorage.getItem(this._offlineKey(sheet)) || '[]');
    return data;
  }

  _offlineWrite(sheet, row) {
    const data = this._offlineRead(sheet);
    if (!row.id) row.id = 'id_' + Date.now() + '_' + Math.random().toString(36).substr(2, 6);
    row.atualizado_em = new Date().toISOString();
    data.push(row);
    localStorage.setItem(this._offlineKey(sheet), JSON.stringify(data));
    return { success: true, id: row.id, row, _offline: true };
  }

  _offlineUpdate(sheet, id, updates) {
    const data = this._offlineRead(sheet);
    const idx = data.findIndex(r => r.id === id);
    if (idx === -1) return { error: 'id não encontrado', _offline: true };
    data[idx] = { ...data[idx], ...updates, atualizado_em: new Date().toISOString() };
    localStorage.setItem(this._offlineKey(sheet), JSON.stringify(data));
    return { success: true, _offline: true };
  }

  _offlineDelete(sheet, id) {
    let data = this._offlineRead(sheet);
    data = data.filter(r => r.id !== id);
    localStorage.setItem(this._offlineKey(sheet), JSON.stringify(data));
    return { success: true, _offline: true };
  }

  // ============ CACHE HELPERS ============

  _isCacheFresh(key) {
    if (!this.cache.has(key)) return false;
    const ts = this.cacheTimestamps.get(key);
    return ts && (Date.now() - ts) < this.cacheTTL;
  }

  _invalidateCache(key) {
    this.cache.delete(key);
    this.cacheTimestamps.delete(key);
  }
}

// Auto-init com URL configurada via meta tag ou window var
(function() {
  if (typeof window === 'undefined') return;
  const apiUrl = window.SHEETS_API_URL ||
                 document.querySelector('meta[name="sheets-api-url"]')?.content ||
                 null;
  window.sheetsClient = new SheetsClient(apiUrl);
  window.SheetsClient = SheetsClient;
})();
