#!/usr/bin/env bash

set -euo pipefail

ROOT=$(git rev-parse --show-toplevel)
ROOTS=$(pants roots --roots-sep=' ')

rm -rf "${ROOT}/dist/export/python/virtualenvs"
pants export --resolve=python-default --resolve=python-dev

PYTHON=$(find -L "$ROOT/dist/export/python/virtualenvs/python-default" -name python -type f)
PYTEST=$(find -L "$ROOT/dist/export/python/virtualenvs/python-default" -name pytest -type f)
BLACK=$(find -L "$ROOT/dist/export/python/virtualenvs/python-dev" -name black -type f)
MYPY=$(find -L "$ROOT/dist/export/python/virtualenvs/python-dev" -name mypy -type f)
RUFF=$(find -L "$ROOT/dist/export/python/virtualenvs/python-dev" -name ruff -type f)

$PYTHON -c "print('PYTHONPATH=\"./' + ':./'.join(\"${ROOTS}\".split()) + ':\$PYTHONPATH\"')" > ${ROOT}/.env

# Using typeCheckingMode=basic as I've found typing incompatibilities with mypy
settings=$(cat <<EOF
{
  "[python]": {
    "editor.formatOnSave": true,
    "editor.formatOnSaveMode": "file",
    "editor.codeActionsOnSave": {
      "source.fixAll": true
    },
  },
  "python.envFile": "\${workspaceFolder}/.env",
  "python.testing.pytestEnabled": true,
  "python.terminal.activateEnvironment": true,
  "python.defaultInterpreterPath": "$PYTHON",
  "python.testing.pytestPath": "$PYTEST",
  "black-formatter.path": [
    "$BLACK"
  ],
  "mypy-type-checker.path": [
    "$MYPY"
  ],
  "ruff.interpreter": [
    "$PYTHON"
  ],
  "ruff.lint.args": [
    "--config=./pyproject.toml"
  ],
  "ruff.path": [
    "$RUFF"
  ],
}
EOF
)

if [ ! -f "$ROOT/.vscode/settings.json" ]; then
  mkdir -p "$ROOT/.vscode"
  touch "$ROOT/.vscode/settings.json"
fi
echo "$settings" | tee "$ROOT/.vscode/settings.json"
echo ""
echo "Run: >Python: Clear cache and reload window"
echo "in VSCode to pick up the new environment changes"
