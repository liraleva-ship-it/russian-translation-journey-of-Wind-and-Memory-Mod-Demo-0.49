/*
    jsondb-choice-fix — self-healing patch addon for Translator++

    Restores the JsonDB.isTranslatableProperties() guards inside
    JsonDB.prototype.fetchCommandList() for two RPG Maker command codes:

        case 102 — Choices       (skip non-translatable choice strings)
        case 402 — Choice options (skip non-translatable option strings)

    Why: the heavy parse runs in the rmrgss worker thread
    (www/addons/rmrgss/JsonInterface/JsonDB.worker.js -> require JsonDB.js).
    Without these guards the worker throws when a choice / choice-option
    value is not a translatable string, which crashes the worker and drags
    the rest of the batch parse down with it.

    The patch edits JsonDB.js on disk and is idempotent, so it can run on
    every launch and will automatically re-apply itself after a Translator++
    or rmrgss update overwrites the core file. The freshly-spawned worker
    threads read the patched file from disk, so the fix reaches the worker.
*/

const fs = require('fs');
const nwPath = require('path');

(function patchJsonDB() {
    const target = nwPath.join(__dirname, '..', 'rmrgss', 'JsonInterface', 'JsonDB.js');

    let src;
    try {
        src = fs.readFileSync(target, 'utf8');
    } catch (e) {
        console.warn('[jsondb-choice-fix] JsonDB.js not found, skipping:', e.message);
        return;
    }

    const original = src;

    // --- case 102: guard each choice inside the forEach loop ---
    // Anchor on the existing body line so we inherit its exact indentation.
    if (!src.includes('if (!JsonDB.isTranslatableProperties(choiceText))')) {
        src = src.replace(
            /([ \t]*)(const choiceContext = \[\.\.\.parentContext, "list", i, `Choices )/,
            (m, ind, rest) =>
                `${ind}if (!JsonDB.isTranslatableProperties(choiceText)) return;\n${ind}${rest}`
        );
    }

    // --- case 402: guard the choice-option registration ---
    if (!src.includes('if (JsonDB.isTranslatableProperties(choiceOptionText))')) {
        src = src.replace(
            /([ \t]*)this\.registerStringObject\(command\['__symbol__@parameters'\], 1, choiceContext\);/,
            (m, ind) =>
                `${ind}if (JsonDB.isTranslatableProperties(choiceOptionText)) {\n` +
                `${ind}    this.registerStringObject(command['__symbol__@parameters'], 1, choiceContext);\n` +
                `${ind}}`
        );
    }

    if (src === original) {
        console.log('[jsondb-choice-fix] Guards already present, nothing to do.');
        return;
    }

    try {
        fs.writeFileSync(target, src, 'utf8');
        console.log('[jsondb-choice-fix] Guards (re)applied to JsonDB.js.');
    } catch (e) {
        console.warn('[jsondb-choice-fix] Failed to write JsonDB.js:', e.message);
    }
})();
