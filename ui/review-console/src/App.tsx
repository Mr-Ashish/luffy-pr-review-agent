import { useCallback, useEffect, useState } from "react";
import { Renderer } from "@openuidev/react-lang";
import { openuiChatLibrary } from "@openuidev/react-ui/genui-lib";

/**
 * Luffy Review Console — Phase 2+3
 * Fixture OpenUI Lang + paste/upload path for real artifacts.
 */
export default function App() {
  const [lang, setLang] = useState<string>("");
  const [error, setError] = useState<string>("");
  const [status, setStatus] = useState<string>("Loading fixture…");
  const [paste, setPaste] = useState<string>("");

  const applyLang = useCallback((text: string, label: string) => {
    setError("");
    setLang(text);
    setStatus(`${label} · ${text.length} chars · openuiChatLibrary`);
  }, []);

  useEffect(() => {
    let cancelled = false;
    (async () => {
      try {
        const res = await fetch("/fixtures/review.openui");
        if (!res.ok) {
          throw new Error(
            `HTTP ${res.status} loading /fixtures/review.openui — run npm run copy-fixture`,
          );
        }
        const text = await res.text();
        if (!cancelled) applyLang(text, "Fixture Odoo PR #3");
      } catch (e) {
        if (!cancelled) {
          setError(String(e));
          setStatus("Failed to load fixture");
        }
      }
    })();
    return () => {
      cancelled = true;
    };
  }, [applyLang]);

  const onFile = async (file: File | null) => {
    if (!file) return;
    const text = await file.text();
    if (file.name.endsWith(".openui") || text.trimStart().startsWith("root =")) {
      applyLang(text, `File ${file.name}`);
      return;
    }
    setError(
      "This file does not look like OpenUI Lang (expected `root = …`). " +
        "Convert with: python3 scripts/review-to-openui.py --review review.md -o out.openui",
    );
  };

  return (
    <div className="app">
      <header className="topbar">
        <div>
          <h1>Luffy Review Console</h1>
          <p>OpenUI generative UI for Luffy PR reviews</p>
        </div>
        <span className="badge">OpenUI × Luffy</span>
      </header>

      <div className="toolbar">
        <label className="file-btn">
          Load .openui
          <input
            type="file"
            accept=".openui,.txt,text/plain"
            hidden
            onChange={(e) => onFile(e.target.files?.[0] ?? null)}
          />
        </label>
        <button
          type="button"
          className="file-btn"
          onClick={() => {
            if (!paste.trim()) {
              setError("Paste OpenUI Lang (starts with root =) first");
              return;
            }
            applyLang(paste, "Pasted program");
          }}
        >
          Render paste
        </button>
      </div>

      <textarea
        className="paste"
        placeholder="Paste OpenUI Lang here (root = Stack(…)) or load a .openui file"
        value={paste}
        onChange={(e) => setPaste(e.target.value)}
        rows={4}
      />

      <div className="status">{status}</div>
      {error ? <div className="error">{error}</div> : null}

      <div className="panel">
        {lang ? (
          <Renderer library={openuiChatLibrary} response={lang} />
        ) : !error ? (
          <p className="status">Waiting for OpenUI Lang…</p>
        ) : null}
      </div>
    </div>
  );
}
