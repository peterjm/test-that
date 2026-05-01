# test-that

`tt` (alias for `test-that`) is a small CLI that detects which test harness a project uses (Rails, Ruby/Minitest, RSpec, or pytest via uv) and runs the right command for the tests you've changed or selected.

## Configuration

`tt` reads `.test_that.json` from the current directory by default (override with `-c`). Recognized keys:

| Key                 | Type    | Description                                                                                |
| ------------------- | ------- | ------------------------------------------------------------------------------------------ |
| `all`               | boolean | Same as passing `--all`.                                                                   |
| `failed`            | boolean | Same as passing `--failed`.                                                                |
| `verbose`           | boolean | Same as passing `--verbose`.                                                               |
| `default_directory` | string  | Before detecting a harness, chdir into this subdirectory if it exists.                     |
| `override`          | object  | Override harness commands. See `lib/test_that/test_harness/override.rb`.                   |

### `default_directory` and monorepos

If your repo is polyglot — say a `py/` Python subproject alongside other code — put a `.test_that.json` at the repo root with:

```json
{ "default_directory": "py" }
```

Now `tt` invoked from the repo root will route into `py/` and pick up the Python harness there. Test-file arguments are translated automatically: `tt py/test_foo.py` from the repo root becomes `pytest test_foo.py` inside `py/`.

### Running from a subdirectory

Inside a git repository, `tt` walks up from your current directory until it finds a directory where one of its harnesses is enabled (e.g. `pyproject.toml` for Python, `test/` for Ruby/Rails). The walk stops at the git repo root, so `tt` never escapes the repo. If the walk doesn't find a harness — or you're not in a git repo at all — `tt` runs in your current directory, which preserves the previous behavior.

Test-file arguments are translated automatically across the walk-up. From `py/some/sub`, `tt ../../test_foo.py` becomes `pytest test_foo.py` inside `py/`.
