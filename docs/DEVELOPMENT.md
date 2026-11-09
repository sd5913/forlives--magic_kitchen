# Development baseline

I am preparing the repository for shared implementation while my teammates and I discuss the design. This baseline checks repository files and the [interaction input contract](INPUT-ARCHITECTURE.md); it does not select a game engine or implement camera interaction.

## Run the checks

Install Git and Python 3.9 or later. No Python packages are required. From the repository root:

```sh
# macOS / Linux
python3 tools/check_repository.py
python3 -m unittest discover -s tests -v
```

```powershell
# Windows with the Python launcher
py -3 tools/check_repository.py
py -3 -m unittest discover -s tests -v
```

The script reads Git-tracked and non-ignored untracked Markdown, Python, JSON, YAML and Godot text files. It reports unresolved conflict markers, UTF-8 decoding errors, invalid Python/JSON syntax and missing or case-mismatched simple inline Markdown file links. Exit code 0 means these checks passed, 1 means a file check failed, and 2 means Git could not list the checkout.

The file checker does not execute the game, validate YAML/Godot syntax, visit external links, inspect Markdown reference links/anchors or scan for secrets. GitHub Actions runs the file checker and interaction contract tests on Linux, Windows and macOS for pushes and pull requests. These checks do not establish that a teammate can play.

## Shared files

- `.editorconfig` suggests UTF-8 and LF text, with tabs for GDScript.
- `.gitattributes` normalises selected text formats and preserves binary assets.
- `.gitignore` excludes local environment files, Python/Godot caches and root export folders. Keep source assets, `project.godot` and Godot UID files in version control when they exist.

These rules do not remove files already tracked by Git. I will review changes before committing, especially new assets and configuration.

## Before adding the engine

I need to reconcile existing local work with the team, agree the engine/version and identify who owns the first playable slice. Then I can add the actual launch command and a game-specific smoke check. The Python script here is a development utility, not a decision to build the game in Python.

See [shared status and handoff](PROJECT-STATUS.md) before working from another computer.
