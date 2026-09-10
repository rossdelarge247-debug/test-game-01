#!/usr/bin/env python3
"""Rebuild pinned gates from git history, then add a static game/history shell."""
import hashlib
import html
import json
import os
from pathlib import Path
import re
import shutil
import subprocess
import tarfile
import tempfile

ROOT = Path(__file__).resolve().parents[1]
WEB = ROOT / "build/web"
LOGS = ROOT / "build/validation"


def run_checked(args, name):
    result = subprocess.run(args, cwd=ROOT, text=True, stdout=subprocess.PIPE, stderr=subprocess.STDOUT)
    (LOGS / f"{name}.log").write_text(result.stdout)
    if result.returncode or re.search(r"(^|\s)(SCRIPT ERROR|ERROR):", result.stdout):
        print(result.stdout)
        raise RuntimeError(f"{name} failed")


STYLE = """
*{box-sizing:border-box}body{margin:0;background:#102025;color:#e5eeee;font:16px system-ui,sans-serif}
a{color:#f0d48c}a:focus-visible{outline:3px solid #f0d48c;outline-offset:3px}
header{min-height:48px;padding:10px 18px;display:flex;gap:16px;align-items:center;flex-wrap:wrap;border-bottom:1px solid #40585e}
header strong{margin-right:auto;font-size:15px}header a{padding:4px;font-size:14px}
.player{height:100vh;height:100dvh;display:flex;flex-direction:column}.player iframe{flex:1;width:100%;min-height:0;border:0;background:#000}
main{max-width:900px;margin:auto;padding:32px 22px}h1{font-size:32px;margin:0 0 10px}
p{color:#b7ced0;line-height:1.6}.cards{display:grid;grid-template-columns:repeat(auto-fit,minmax(260px,1fr));gap:18px;margin-top:28px}
article{background:#20363d;border:1px solid #426068;border-radius:12px;padding:22px}article h2{font-size:21px;margin-top:0}
.play{display:inline-block;padding:12px 18px;background:#e9c777;color:#15272b;border-radius:7px;font-weight:700;text-decoration:none}
"""


def document(title, body, player=False):
    return f'''<!doctype html>
<html lang="en"><head><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1">
<title>{html.escape(title)} · Acaciana Fub</title><style>{STYLE}</style></head>
<body class="{'player' if player else 'history'}">{body}</body></html>'''


def shell(title, game_path, history_path, latest_path):
    return document(title, f'''<header><strong>{html.escape(title)}</strong>
<a href="{latest_path}">Latest test</a><a href="{history_path}">Test history</a></header>
<iframe src="{game_path}" title="{html.escape(title)} game" allow="autoplay; fullscreen; gamepad" allowfullscreen></iframe>''', True)


def main():
    manifest = json.loads((ROOT / "history/gates.json").read_text())
    LOGS.mkdir(parents=True, exist_ok=True)
    if not (WEB / "index.html").is_file() or (WEB / "play").exists():
        raise RuntimeError("Run export-web.sh before building history")
    # Keep all current export assets together so relative Godot URLs still work.
    current_files = list(WEB.iterdir())
    (WEB / "play").mkdir()
    for entry in current_files:
        shutil.move(str(entry), WEB / "play" / entry.name)
    (WEB / "index.html").write_text(shell(manifest["current_title"], "play/", "history/", "./"))
    evidence = []
    seen = set()
    with tempfile.TemporaryDirectory(prefix="acaciana-history-") as temporary:
        temp = Path(temporary)
        engines = {}
        for gate in manifest["gates"]:
            gate_id, sha = gate["id"], gate["commit"]
            if not re.fullmatch(r"gate-[0-9]+", gate_id) or gate_id in seen:
                raise ValueError("Gate IDs must be unique gate-N slugs")
            if not re.fullmatch(r"[0-9a-f]{40}", sha):
                raise ValueError("Pin a complete commit SHA, never a moving branch")
            seen.add(gate_id)
            version, release = gate["godot_version"], gate["godot_release"]
            if not re.fullmatch(r"[0-9]+\.[0-9]+(?:\.[0-9]+)?", version) or release != "stable":
                raise ValueError("Historical gates require a pinned stable engine version")
            key = (version, release)
            if key not in engines:
                installed = shutil.which("godot")
                actual = subprocess.check_output([installed, "--version"], text=True).strip() if installed else ""
                if actual.startswith(f"{version}.{release}."):
                    engines[key] = installed
                else:
                    install_dir = temp / "engines" / f"{version}-{release}"
                    env = dict(os.environ, GODOT_VERSION=version, GODOT_RELEASE=release, GODOT_INSTALL_DIR=str(install_dir))
                    subprocess.run(["bash", str(ROOT / "scripts/install-godot.sh")], cwd=ROOT, env=env, check=True)
                    engines[key] = str(install_dir / "godot")
            snapshot = temp / gate_id
            snapshot.mkdir()
            archive = temp / f"{gate_id}.tar"
            with archive.open("wb") as stream:
                subprocess.run(["git", "archive", "--format=tar", sha], cwd=ROOT, stdout=stream, check=True)
            with tarfile.open(archive) as source:
                source.extractall(snapshot, filter="data")
            game = WEB / "history" / gate_id / "game"
            game.mkdir(parents=True)
            engine = engines[key]
            run_checked([engine, "--headless", "--path", str(snapshot), "--editor", "--quit"], f"history-{gate_id}-import")
            run_checked([engine, "--headless", "--path", str(snapshot), "--export-release", "Web", str(game / "index.html")], f"history-{gate_id}-export")
            for suffix in ["html", "js", "wasm", "pck"]:
                if not (game / f"index.{suffix}").stat().st_size:
                    raise RuntimeError(f"Missing {gate_id} export asset")
            (game.parent / "index.html").write_text(shell(gate["title"], "game/", "../", "../../"))
            record = dict(gate, pck_sha256=hashlib.sha256((game / "index.pck").read_bytes()).hexdigest())
            (game.parent / "provenance.json").write_text(json.dumps(record, indent=2) + "\n")
            evidence.append(record)
    cards = "".join(f'''<article><h2>{html.escape(g['title'])}</h2><p>{html.escape(g['description'])}</p>
<a class="play" href="{g['id']}/">Play {html.escape(g['title'])}</a></article>''' for g in manifest["gates"])
    (WEB / "history/index.html").write_text(document("Test history", f'''<header><strong>ACACIANA FUB</strong><a href="../">Latest test</a></header>
<main><h1>Test history</h1><p>Play the earlier gates and see how the game is growing. Each version keeps the controls and mechanics it had at that stage.</p><div class="cards">{cards}</div></main>'''))
    (LOGS / "history-provenance.json").write_text(json.dumps(evidence, indent=2) + "\n")
    print(f"HISTORY_BUILT gates={len(evidence)}")


if __name__ == "__main__":
    main()
