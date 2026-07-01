/*
 * Lines Checker — translator++ addon.
 * Hooks afterChange on the active grid and talks to LinesCheckerServer inside
 * the game:
 *   • per-cell edit  → debounce 300мс → POST /measure       → decorate
 *   • file load/open → один batch    → POST /measure_batch  → decorate all
 *
 * Cell states:
 *   pending  → yellow tint while the request is in flight (per-cell edit only)
 *   overflow → red tint when the engine reports the text doesn't fit
 *   ok       → no class
 */

(function() {
  // ---- File logging fallback (DevTools disabled in NW.js production build) ----
  let logFile = null;
  try {
    const path = require("path");
    const fs   = require("fs");
    logFile = path.join(__dirname, "linesChecker.log");
    fs.writeFileSync(logFile, `[${new Date().toISOString()}] addon script started\n`, { flag: "w" });
  } catch (e1) {
    try {
      const path = require("path");
      const fs   = require("fs");
      logFile = path.join(nw.App.dataPath, "linesChecker.log");
      fs.writeFileSync(logFile, `[${new Date().toISOString()}] addon script started (fallback path)\n`, { flag: "w" });
    } catch (e2) {
      logFile = null;
    }
  }

  function log(...args) {
    const msg = `[${new Date().toISOString()}] ${args.map(a => typeof a === "string" ? a : JSON.stringify(a)).join(" ")}\n`;
    try { if (logFile) require("fs").appendFileSync(logFile, msg); } catch {}
    try { console.log("[LinesChecker]", ...args); } catch {}
  }

  log("addon loading; logFile =", logFile || "(unavailable)");

  const PORT             = 27420;
  const BASE_URL         = `http://127.0.0.1:${PORT}`;
  const DEBOUNCE_MS      = 300;
  const PING_INTERVAL    = 10000;
  const FILE_POLL_INTERVAL = 700;
  // Полный проход (все файлы) шлём пачками — один гигантский запрос блокирует
  // сервер на десятки секунд без обратной связи. Чанк даёт прогресс + yield UI.
  const FULL_SCAN_CHUNK  = 300;

  // ---- Original-column checking ----
  // По умолчанию проверяем только перевод (последний непустой столбец справа).
  // Юзер может включить проверку и оригинала (col 0) — например чтобы убедиться,
  // что исходные строки сами влезают в окно. Состояние персистим в localStorage.
  let checkOriginal = false;
  try { checkOriginal = localStorage.getItem("lc-check-original") === "1"; } catch (e) {}
  function setCheckOriginal(on) {
    checkOriginal = !!on;
    try { localStorage.setItem("lc-check-original", checkOriginal ? "1" : "0"); } catch (e) {}
  }

  // ---- Context inference ----
  function inferContext(ctxString) {
    if (!ctxString) return "dialog";
    if (ctxString.includes("/note"))        return null;          // skip game tags
    if (ctxString.includes("/description")) return "description";
    if (ctxString.includes("/Choices"))     return "choice";      // 102/list/.../Choices N/M
    return "dialog";
  }

  // ---- HTTP ----
  async function measure(text, context) {
    const res = await fetch(`${BASE_URL}/measure`, {
      method:  "POST",
      headers: { "Content-Type": "application/json" },
      body:    JSON.stringify({ text, context }),
    });
    if (!res.ok) throw new Error(`HTTP ${res.status}`);
    return await res.json();
  }

  // NDJSON-конверт: сервер не парсит вложенные массивы. Реальных \n внутри
  // JSON-строки быть не должно — \n в тексте JSON.stringify экранирует как \\n.
  async function measureBatch(items) {
    const body = items.map(it => JSON.stringify(it)).join("\n");
    const res  = await fetch(`${BASE_URL}/measure_batch`, {
      method:  "POST",
      headers: { "Content-Type": "application/x-ndjson" },
      body,
    });
    if (!res.ok) throw new Error(`HTTP ${res.status}`);
    return await res.json();
  }

  async function ping() {
    try {
      const res = await fetch(`${BASE_URL}/ping`, { method: "GET" });
      return res.ok;
    } catch (e) {
      return false;
    }
  }

  // ---- Cell decoration ----
  // state: "pending" | "overflow" | "ok"
  // skipRender: для batch-апдейтов вызывающий должен дёрнуть trans.grid.render()
  //             один раз в конце — иначе render() по ячейке × 500 ячеек = фриз.
  function setCellState(row, col, state, tooltip, skipRender) {
    try {
      if (!trans || !trans.grid) return;
      let className = "";
      if (state === "pending")  className = "lc-pending";
      if (state === "overflow") className = "lc-overflow";
      trans.grid.setCellMeta(row, col, "className", className);
      if (tooltip) {
        trans.grid.setCellMeta(row, col, "comment", { value: tooltip });
      } else {
        trans.grid.setCellMeta(row, col, "comment", undefined);
      }
      if (!skipRender) trans.grid.render();

      // Direct DOM fallback for setups where setCellMeta gets overridden.
      const td = trans.grid.getCell(row, col);
      if (td && td.classList) {
        td.classList.toggle("lc-pending",  state === "pending");
        td.classList.toggle("lc-overflow", state === "overflow");
        if (tooltip) td.title = tooltip; else td.removeAttribute("title");
      }
    } catch (e) {
      log("setCellState failed:", e.message);
    }
  }

  // ---- Context lookup ----
  // trans.context не существует на верхнем уровне — в translator++ контекст
  // лежит в trans.project.files[<id>].context[row] (см. ui.js:3398).
  function currentFile() {
    try {
      const id = trans.getSelectedId();
      return id ? trans.project.files[id] : null;
    } catch (e) { return null; }
  }

  function contextForRow(row) {
    const file = currentFile();
    if (!file || !file.context) return "";
    const ctxRow = file.context[row] || [];
    return ctxRow[0] || "";
  }

  // ---- Tooltip ----
  function buildTooltip(data) {
    const issues = [];
    for (const line of data.lines || []) {
      if (line.fits) continue;
      if (line.width !== undefined) {
        issues.push(`«${line.text}» — ${line.width}px > ${data.max_width}px`);
      } else if (line.length !== undefined) {
        issues.push(`«${line.text}» — ${line.length} > ${data.max_chars}`);
      }
    }
    if (data.max_lines !== null && data.lines_count > data.max_lines) {
      issues.push(`строк: ${data.lines_count} > ${data.max_lines}`);
    }
    return issues.join("\n");
  }

  function applyResult(row, col, data, skipRender) {
    const tooltip = data.fits ? null : buildTooltip(data);
    setCellState(row, col, data.fits ? "ok" : "overflow", tooltip, skipRender);
  }

  // Однострочное резюме проблемы для строки сводки («680px > 614px, строк 2 > 1»).
  function summarizeIssues(data) {
    const parts = [];
    for (const line of data.lines || []) {
      if (line.fits) continue;
      if (line.width !== undefined)       parts.push(`${line.width}px > ${data.max_width}px`);
      else if (line.length !== undefined) parts.push(`${line.length} > ${data.max_chars} симв.`);
    }
    if (data.max_lines !== null && data.lines_count > data.max_lines) {
      parts.push(`строк ${data.lines_count} > ${data.max_lines}`);
    }
    return parts.join(", ");
  }

  // ---- Per-cell debounce ----
  const timers = new Map();
  const cellKey = (row, col) => `${row}:${col}`;

  async function validate(row, col, text) {
    const context = inferContext(contextForRow(row));
    if (!context || !text || !text.trim()) {
      // skipRender=true: одиночную ячейку красит DOM-фолбэк в setCellState,
      // полный trans.grid.render() на каждый правленый текст = фриз грида.
      setCellState(row, col, "ok", null, true);
      return;
    }
    try {
      applyResult(row, col, await measure(text, context), true);
    } catch (err) {
      log("measure failed:", err.message);
      setCellState(row, col, "ok", null, true);
    }
  }

  function onAfterChange(changes, source) {
    if (!changes) return;
    // translator++ грузит данные не через loadData (там стоит stub), полагаемся
    // на file-change поллинг ниже. Игнорируем initial / programmatic события.
    if (source === "loadData" || source === "lc/refresh") return;

    for (const change of changes) {
      const [row, col, _oldVal, newVal] = change;
      if (col === 0 && !checkOriginal) continue;

      // Immediate feedback: yellow tint while we wait for debounce + measure.
      // skipRender=true — красим только эту td через DOM-фолбэк, без полной
      // перерисовки грида (она и вызывала лаг при правке ячеек).
      setCellState(row, col, "pending", null, true);

      const key = cellKey(row, col);
      clearTimeout(timers.get(key));
      const t = setTimeout(() => {
        timers.delete(key);
        validate(row, col, newVal == null ? "" : String(newVal));
      }, DEBOUNCE_MS);
      timers.set(key, t);
    }
  }

  // ---- Initial sweep ----
  // На loadData (открытие/перезагрузка файла) собираем все непустые переводы
  // и шлём их одним пакетом на /measure_batch. Альтернатива — по запросу на
  // ячейку — слишком долгая (300+ запросов × 300мс debounce + сеть).
  // translator++ хранит несколько слотов перевода (Initial / Machine / Better /
  // Best) — за актуальный берётся последний непустой справа. Col 0 — оригинал.
  function activeTranslation(dataRow) {
    for (let c = dataRow.length - 1; c >= 1; c--) {
      const v = dataRow[c];
      if (typeof v === "string" && v.trim()) return { col: c, text: v };
    }
    return null;
  }

  // Какие ячейки строки измерять: перевод (col ≥ 1) всегда + оригинал (col 0),
  // если включена соответствующая проверка. Возвращает массив { col, text }.
  function cellsToCheck(dataRow) {
    const out = [];
    const active = activeTranslation(dataRow);
    if (active) out.push(active);
    if (checkOriginal) {
      const orig = dataRow[0];
      // не дублируем, если перевода нет и activeTranslation вернул бы col 0
      if (typeof orig === "string" && orig.trim()) out.push({ col: 0, text: orig });
    }
    return out;
  }

  let sweepInFlight = false;
  async function runInitialSweep() {
    if (sweepInFlight) { log("sweep skipped: already in flight"); return; }
    const file = currentFile();
    if (!file) { log("sweep skipped: currentFile() null"); return; }
    if (!file.data) { log("sweep skipped: file.data missing"); return; }

    let nonEmpty = 0, ctxHit = 0;
    const tasks = [];
    for (let row = 0; row < file.data.length; row++) {
      const dataRow = file.data[row];
      if (!dataRow) continue;
      const cells = cellsToCheck(dataRow);
      if (!cells.length) continue;
      nonEmpty++;
      const ctxStr  = (file.context && file.context[row] && file.context[row][0]) || "";
      const context = inferContext(ctxStr);
      if (!context) continue;
      ctxHit++;
      for (const cell of cells) {
        tasks.push({ row, col: cell.col, payload: { text: cell.text, context } });
      }
    }
    log(`sweep candidates: rows=${file.data.length} nonEmpty=${nonEmpty} ctxHit=${ctxHit}`);
    if (!tasks.length) return;

    sweepInFlight = true;
    const fileId = trans.getSelectedId();
    const el = document.getElementById("lc-status");
    if (el) el.textContent = `LinesChecker: проверка ${tasks.length}…`;
    try {
      const data = await measureBatch(tasks.map(t => t.payload));
      // Юзер мог переключить файл пока запрос летал — индексы стали бы кошмаром.
      if (trans.getSelectedId() !== fileId) {
        log("file switched during sweep, skipping decoration");
        return;
      }
      const results = data.results || [];
      let overflow = 0;
      // setCellMeta×N + getCell×N очень дороги в Handsontable — для большинства
      // ячеек (fits=true) никакой меты ставить не надо, просто пропускаем.
      // Точечное снятие старых пометок отрабатывает onAfterChange.
      for (let i = 0; i < tasks.length; i++) {
        const r = results[i];
        if (!r || r.fits) continue;
        applyResult(tasks[i].row, tasks[i].col, r, true);
        overflow++;
      }
      if (overflow) { try { trans.grid.render(); } catch (e) {} }
      log(`sweep done: ${tasks.length} cells, ${overflow} overflow`);
    } catch (err) {
      log("sweep failed:", err.message);
    } finally {
      sweepInFlight = false;
      updateStatus();
    }
  }

  // ---- File-change poll ----
  // trans.js имеет stub trans.grid = {}, реальный grid инициализируется позже,
  // а translator++ не использует loadData при показе файла — afterChange с
  // source="loadData" не приходит. Проще опрашивать selectedId и реагировать
  // на смену, чем копаться во внутренних событиях.
  let lastSelectedId = null;
  function startFilePoll() {
    setInterval(() => {
      let id;
      try { id = trans.getSelectedId(); } catch (e) { return; }
      if (id && id !== lastSelectedId) {
        lastSelectedId = id;
        log("file selected:", id);
        runInitialSweep();
      }
    }, FILE_POLL_INTERVAL);
  }

  // ---- CSS ----
  function injectStyles() {
    if (document.getElementById("lc-styles")) return;
    const style = document.createElement("style");
    style.id = "lc-styles";
    style.textContent = `
      .lc-pending {
        background-color: rgba(255, 200, 60, 0.35) !important;
        transition: background-color 120ms ease;
      }
      .lc-overflow {
        background-color: rgba(255, 70, 70, 0.45) !important;
      }
      .lc-overflow.current {
        background-color: rgba(255, 70, 70, 0.65) !important;
      }

      /* ---- Summary panel ---- */
      #lc-summary {
        position: fixed; top: 40px; right: 20px; width: 560px;
        max-height: 78vh; z-index: 1000000;
        display: flex; flex-direction: column;
        background: #2b2b2b; color: #e6e6e6;
        border: 1px solid #555; border-radius: 5px;
        box-shadow: 0 6px 24px rgba(0,0,0,0.5);
        font-family: "Segoe UI", sans-serif; font-size: 12px;
      }
      #lc-summary .lc-sum-header {
        display: flex; align-items: center; gap: 10px;
        padding: 7px 10px; background: #1f1f1f;
        border-bottom: 1px solid #444; border-radius: 5px 5px 0 0;
      }
      #lc-summary .lc-sum-title { font-weight: bold; }
      #lc-summary .lc-sum-stats { margin-left: auto; color: #bbb; font-size: 11px; }
      #lc-summary .lc-sum-bad { color: #ff7070; }
      #lc-summary .lc-sum-export {
        cursor: pointer; color: #cfe2ff; font-size: 11px;
        border: 1px solid #4a6aa8; border-radius: 3px; padding: 1px 6px;
      }
      #lc-summary .lc-sum-export:hover { background: #4a6aa8; color: #fff; }
      #lc-summary .lc-sum-close { cursor: pointer; color: #aaa; padding: 0 4px; }
      #lc-summary .lc-sum-close:hover { color: #fff; }
      #lc-summary .lc-sum-body { overflow-y: auto; padding: 0 0 4px; }
      #lc-summary .lc-sum-empty { padding: 20px; text-align: center; color: #8fce8f; }
      /* display:contents — чтобы все заголовки файлов липли в одном контейнере
         (теле), а не каждый в своей группе: тогда наверху всегда прибит ровно
         один заголовок и они сменяют друг друга без выезжающих «хвостов». */
      #lc-summary .lc-sum-group { display: contents; }
      #lc-summary .lc-sum-file {
        padding: 5px 10px; background: #353535; color: #cfe2ff;
        font-family: monospace; position: sticky; top: 0; z-index: 2;
      }
      #lc-summary .lc-sum-count {
        float: right; background: #555; border-radius: 8px;
        padding: 0 7px; font-size: 11px;
      }
      #lc-summary .lc-sum-line {
        display: flex; align-items: baseline; gap: 8px;
        padding: 4px 10px 4px 16px; cursor: pointer;
        border-bottom: 1px solid #333;
      }
      #lc-summary .lc-sum-line:hover { background: #3a3f47; }
      #lc-summary .lc-sum-line.selected { background: #45506a; }
      #lc-summary .lc-sum-ctx {
        flex: none; font-size: 10px; padding: 1px 5px; border-radius: 3px;
        background: #666; color: #fff;
      }
      #lc-summary .lc-ctx-description { background: #6a4ca8; }
      #lc-summary .lc-ctx-choice      { background: #2f7d4f; }
      #lc-summary .lc-ctx-dialog      { background: #4a6aa8; }
      #lc-summary .lc-sum-rc { flex: none; color: #888; font-family: monospace; font-size: 11px; }
      #lc-summary .lc-sum-text {
        flex: 1 1 auto; white-space: nowrap; overflow: hidden;
        text-overflow: ellipsis; color: #ddd;
      }
      #lc-summary .lc-sum-issue { flex: none; color: #ff9090; font-size: 11px; white-space: nowrap; }
    `;
    document.head.appendChild(style);
  }

  // ---- Status pill ----
  function ensureStatusPill() {
    let el = document.getElementById("lc-status");
    if (el) return el;
    el = document.createElement("div");
    el.id = "lc-status";
    el.style.cssText = [
      "position: fixed",
      "bottom: 6px",
      "right: 10px",
      "z-index: 999999",
      "padding: 3px 9px",
      "font-size: 11px",
      "font-family: monospace",
      "border-radius: 3px",
      "background: rgba(50,50,50,0.85)",
      "color: #fff",
      "pointer-events: none",
    ].join(";");
    el.textContent = "LinesChecker: …";
    document.body.appendChild(el);
    return el;
  }

  // Пункт «Проверить все файлы» в главном меню Tools (ui.mainMenu). Если меню
  // ещё не готово или API недоступен — тихий фолбэк, аддон всё равно работает
  // (статус-пилюля + проверка открытого файла).
  let menuRegistered = false;
  let origMenuItem = null;
  function origMenuLabel() {
    return `LinesChecker: проверять оригинал — ${checkOriginal ? "вкл ✓" : "выкл"}`;
  }
  function refreshOrigMenuLabel() {
    // addChild возвращает jQuery-объект пункта; текст метки лежит во вложенном
    // <div> (см. darkTheme/dark.js updateMenuLabel).
    try { if (origMenuItem) origMenuItem.find("div").first().text(origMenuLabel()); }
    catch (e) { log("refreshOrigMenuLabel failed:", e.message); }
  }
  // Снимаем пометки со столбца оригинала (col 0) у открытого файла. Нужно при
  // выключении режима — sweep сам старые отметки не чистит (полагается на
  // onAfterChange), так что без этого красные ячейки оригинала зависли бы.
  function clearOriginalDecorations() {
    try {
      const file = currentFile();
      if (!trans || !trans.grid || !file || !file.data) return;
      for (let row = 0; row < file.data.length; row++) {
        setCellState(row, 0, "ok", null, true);
      }
      trans.grid.render();
    } catch (e) { log("clearOriginalDecorations failed:", e.message); }
  }
  function toggleCheckOriginal() {
    setCheckOriginal(!checkOriginal);
    log("checkOriginal ->", checkOriginal);
    refreshOrigMenuLabel();
    if (checkOriginal) {
      runInitialSweep();            // перепроверяем открытый файл под новым режимом
    } else {
      clearOriginalDecorations();   // убираем зависшие пометки оригинала
    }
  }
  function registerMenu() {
    if (menuRegistered) return;
    try {
      if (typeof ui === "undefined" || !ui.onReady || !ui.mainMenu) return;
      ui.onReady(function() {
        try {
          ui.mainMenu.addChild("tools", {
            id: "lineschecker-scan",
            label: "LinesChecker: проверить все файлы",
          }).on("select", function() { runFullScan(); });
          origMenuItem = ui.mainMenu.addChild("tools", {
            id: "lineschecker-toggle-original",
            label: origMenuLabel(),
          });
          origMenuItem.on("select", function() { toggleCheckOriginal(); });
          menuRegistered = true;
          log("menu items registered under Tools ✓");
        } catch (e) { log("addChild failed:", e.message); }
      });
    } catch (e) { log("registerMenu failed:", e.message); }
  }

  async function updateStatus() {
    if (fullScanInFlight) return;   // не затирать прогресс прохода
    const el = ensureStatusPill();
    const ok = await ping();
    if (ok) {
      el.style.background = "rgba(40, 140, 40, 0.85)";
      el.textContent = "LinesChecker: online ✓";
    } else {
      el.style.background = "rgba(170, 40, 40, 0.85)";
      el.textContent = "LinesChecker: offline (start the game)";
    }
  }

  // ---- Full project scan ----
  // Проходим ВСЕ файлы проекта (trans.project.files), а не только открытый.
  // Данные каждого файла доступны без его открытия: .data (строки) и .context.
  // Навигация к ячейке — trans.goTo(row, col, fileId) (см. find.js: клик по
  // результату поиска).
  function collectAllTasks() {
    const tasks = [];
    let files = 0, cells = 0;
    let project;
    try { project = trans.project; } catch (e) { project = null; }
    if (!project || !project.files) return { tasks, files, cells };

    for (const fileId in project.files) {
      const file = project.files[fileId];
      if (!file || !file.data) continue;
      files++;
      for (let row = 0; row < file.data.length; row++) {
        const dataRow = file.data[row];
        if (!dataRow) continue;
        const rowCells = cellsToCheck(dataRow);
        if (!rowCells.length) continue;
        cells++;
        const ctxStr  = (file.context && file.context[row] && file.context[row][0]) || "";
        const context = inferContext(ctxStr);
        if (!context) continue;
        for (const cell of rowCells) {
          tasks.push({ fileId, row, col: cell.col, text: cell.text, context });
        }
      }
    }
    return { tasks, files, cells };
  }

  let fullScanInFlight = false;
  function scanProgress(text) {
    const el = document.getElementById("lc-status");
    if (el) { el.style.background = "rgba(40, 90, 150, 0.9)"; el.textContent = text; }
  }
  async function runFullScan() {
    if (fullScanInFlight) { log("full scan skipped: already in flight"); return; }
    if (!(await ping())) {
      log("full scan aborted: server offline");
      try { alert("LinesChecker: сервер недоступен.\nЗапусти игру, чтобы проверить все файлы."); } catch (e) {}
      updateStatus();
      return;
    }
    const { tasks, files, cells } = collectAllTasks();
    log(`full scan: files=${files} cells=${cells} measurable=${tasks.length}`);
    if (!tasks.length) { showSummary([], { files, cells, measured: 0 }); return; }

    fullScanInFlight = true;
    scanProgress("LinesChecker: проверка…");
    const overflows = [];
    try {
      for (let i = 0; i < tasks.length; i += FULL_SCAN_CHUNK) {
        const chunk = tasks.slice(i, i + FULL_SCAN_CHUNK);
        const done  = Math.min(i + chunk.length, tasks.length);
        scanProgress(`LinesChecker: проверка ${done}/${tasks.length}…`);
        let results = [];
        try {
          const data = await measureBatch(chunk.map(t => ({ text: t.text, context: t.context })));
          results = data.results || [];
        } catch (err) {
          log("full scan chunk failed:", err.message);
        }
        for (let j = 0; j < chunk.length; j++) {
          const r = results[j];
          if (!r || r.fits) continue;
          overflows.push(Object.assign({}, chunk[j], { result: r }));
        }
      }
      log(`full scan done: ${overflows.length} overflow of ${tasks.length}`);
      showSummary(overflows, { files, cells, measured: tasks.length });
    } catch (err) {
      log("full scan failed:", err.message);
    } finally {
      fullScanInFlight = false;
      updateStatus();
    }
  }

  // ---- Summary panel ----
  function esc(s) {
    return String(s == null ? "" : s)
      .replace(/&/g, "&amp;").replace(/</g, "&lt;").replace(/>/g, "&gt;");
  }

  function closeSummary() {
    const el = document.getElementById("lc-summary");
    if (el) el.remove();
  }

  // Перетаскивание панели за шапку. Переводим на абсолютные left/top и снимаем
  // right, чтобы позиционирование стало двусторонним.
  function makeDraggable(panel, handle) {
    handle.style.cursor = "move";
    handle.addEventListener("mousedown", function(e) {
      if (e.target.classList.contains("lc-sum-close")) return;
      e.preventDefault();
      const rect = panel.getBoundingClientRect();
      const offX = e.clientX - rect.left;
      const offY = e.clientY - rect.top;
      panel.style.right  = "auto";
      panel.style.left   = rect.left + "px";
      panel.style.top    = rect.top + "px";
      function onMove(ev) {
        const x = Math.max(0, Math.min(window.innerWidth  - 40, ev.clientX - offX));
        const y = Math.max(0, Math.min(window.innerHeight - 24, ev.clientY - offY));
        panel.style.left = x + "px";
        panel.style.top  = y + "px";
      }
      function onUp() {
        document.removeEventListener("mousemove", onMove);
        document.removeEventListener("mouseup", onUp);
      }
      document.addEventListener("mousemove", onMove);
      document.addEventListener("mouseup", onUp);
    });
  }

  // ---- Markdown export ----
  // Двузначное дополнение для имени файла-отчёта (без зависимостей).
  function pad2(n) { return n < 10 ? "0" + n : "" + n; }
  function reportFileName() {
    const d = new Date();
    return `lineschecker-${d.getFullYear()}${pad2(d.getMonth() + 1)}${pad2(d.getDate())}` +
           `-${pad2(d.getHours())}${pad2(d.getMinutes())}.md`;
  }

  function buildMarkdown(overflows, stats) {
    const lines = [];
    lines.push("# LinesChecker — отчёт");
    lines.push("");
    lines.push(`_${new Date().toLocaleString()}_`);
    lines.push("");
    lines.push(`**файлов:** ${stats.files} · **ячеек:** ${stats.measured} · ` +
               `**переполнений:** ${overflows.length}`);
    lines.push("");

    if (!overflows.length) {
      lines.push("✓ Переполнений не найдено.");
      lines.push("");
      return lines.join("\n");
    }

    // группировка по файлам с сохранением порядка появления
    const byFile = new Map();
    for (const o of overflows) {
      if (!byFile.has(o.fileId)) byFile.set(o.fileId, []);
      byFile.get(o.fileId).push(o);
    }

    for (const [fileId, items] of byFile) {
      lines.push(`## 📄 ${fileId}  (${items.length})`);
      lines.push("");
      for (const o of items) {
        const issue = summarizeIssues(o.result) || "переполнение";
        // текст в одну строку: реальные переводы строк помечаем ⏎
        const text = String(o.text == null ? "" : o.text).replace(/\n/g, " ⏎ ");
        lines.push(`- **${o.row}:${o.col}** \`${o.context}\` — ${issue}`);
        lines.push(`  «${text}»`);
      }
      lines.push("");
    }
    return lines.join("\n");
  }

  // Сохранение через нативный save-as диалог NW.js (скрытый input[nwsaveas]).
  function saveTextFile(defaultName, content) {
    let fs;
    try { fs = require("fs"); } catch (e) { fs = null; }
    const inp = document.createElement("input");
    inp.type = "file";
    inp.setAttribute("nwsaveas", defaultName);
    inp.setAttribute("accept", ".md");
    inp.style.display = "none";
    inp.addEventListener("change", function() {
      const p = this.value;
      document.body.removeChild(inp);
      if (!p) return;
      try {
        if (fs) fs.writeFileSync(p, content, "utf8");
        log("report saved:", p);
        const el = document.getElementById("lc-status");
        if (el) { el.style.background = "rgba(40,140,40,0.9)"; el.textContent = "LinesChecker: отчёт сохранён ✓"; }
        setTimeout(updateStatus, 2500);
      } catch (e) {
        log("saveTextFile failed:", e.message);
        try { alert("LinesChecker: не удалось сохранить файл:\n" + e.message); } catch (e2) {}
      }
    });
    document.body.appendChild(inp);
    inp.click();
  }

  function exportSummary(overflows, stats) {
    try {
      saveTextFile(reportFileName(), buildMarkdown(overflows, stats));
    } catch (e) {
      log("exportSummary failed:", e.message);
    }
  }

  function showSummary(overflows, stats) {
    closeSummary();
    injectStyles();

    // группируем по файлам, сохраняя порядок появления
    const byFile = new Map();
    for (const o of overflows) {
      if (!byFile.has(o.fileId)) byFile.set(o.fileId, []);
      byFile.get(o.fileId).push(o);
    }

    const panel = document.createElement("div");
    panel.id = "lc-summary";

    const header = document.createElement("div");
    header.className = "lc-sum-header";
    header.innerHTML =
      `<span class="lc-sum-title">LinesChecker — сводка</span>` +
      `<span class="lc-sum-stats">файлов: ${stats.files} · ячеек: ${stats.measured} · ` +
      `<b class="lc-sum-bad">переполнений: ${overflows.length}</b></span>` +
      `<span class="lc-sum-export" title="выгрузить в .md">💾 .md</span>` +
      `<span class="lc-sum-close" title="закрыть">✕</span>`;
    header.querySelector(".lc-sum-export")
          .addEventListener("click", () => exportSummary(overflows, stats));
    header.querySelector(".lc-sum-close").addEventListener("click", closeSummary);
    makeDraggable(panel, header);
    panel.appendChild(header);

    const body = document.createElement("div");
    body.className = "lc-sum-body";

    if (overflows.length === 0) {
      const ok = document.createElement("div");
      ok.className = "lc-sum-empty";
      ok.textContent = "Переполнений не найдено ✓";
      body.appendChild(ok);
    }

    for (const [fileId, items] of byFile) {
      const group = document.createElement("div");
      group.className = "lc-sum-group";
      const gh = document.createElement("div");
      gh.className = "lc-sum-file";
      gh.innerHTML = `📄 ${esc(fileId)} <span class="lc-sum-count">${items.length}</span>`;
      group.appendChild(gh);

      for (const o of items) {
        const line = document.createElement("div");
        line.className = "lc-sum-line";
        line.title = "перейти к ячейке";
        const snippet = o.text.replace(/\n/g, "⏎").slice(0, 80);
        line.innerHTML =
          `<span class="lc-sum-ctx lc-ctx-${esc(o.context)}">${esc(o.context)}</span>` +
          `<span class="lc-sum-rc">${o.row}:${o.col}</span>` +
          `<span class="lc-sum-text">${esc(snippet)}</span>` +
          `<span class="lc-sum-issue">${esc(summarizeIssues(o.result))}</span>`;
        line.addEventListener("click", () => {
          try {
            trans.goTo(o.row, o.col, o.fileId);
            panel.querySelectorAll(".lc-sum-line.selected")
                 .forEach(e => e.classList.remove("selected"));
            line.classList.add("selected");
          } catch (e) { log("goTo failed:", e.message); }
        });
        group.appendChild(line);
      }
      body.appendChild(group);
    }

    panel.appendChild(body);
    document.body.appendChild(panel);
  }

  // ---- Init ----
  let attached = false;
  function tryInit() {
    try {
      if (!document.body) {
        setTimeout(tryInit, 300);
        return;
      }

      ensureStatusPill();
      registerMenu();
      injectStyles();
      updateStatus();
      setInterval(updateStatus, PING_INTERVAL);

      if (typeof trans === "undefined" || !trans.grid || typeof trans.grid.addHook !== "function") {
        log("trans.grid not ready; will retry");
        setTimeout(tryInit, 500);
        return;
      }

      if (!attached) {
        trans.grid.addHook("afterChange", onAfterChange);
        attached = true;
        log("hooked into trans.grid afterChange ✓");
        startFilePoll();
      }
    } catch (e) {
      log("tryInit threw:", e.message, e.stack);
      setTimeout(tryInit, 1000);
    }
  }

  tryInit();
})();
