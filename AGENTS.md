# Acaciana Fub project workflow

- Follow the gate order and canon boundaries in `docs/prototype-0.md`. Ross's top-down A Link to the Past clarification supersedes the original handoff's side-view/jump suggestion.
- Preserve playable history when progressing to a new gate. Before changing gameplay for the next gate, ensure the previous tested gate is pinned by full merged commit SHA and matching Godot version in `history/gates.json`. Keep prior entries unchanged; update `current_title` for the latest test. Follow `docs/test-history.md`.
- Keep keyboard and touch controls usable together. Run the existing movement/combat checks and relevant browser checks before declaring a new gate ready.
- Gate implementation does not constitute Ross's acceptance. Record his actual playback feedback before progressing. Keep unconfirmed lore as explicit placeholders.
- Never put credentials in source. Continue using the existing manual GitHub Actions deployment workflow and configured repository secrets.
