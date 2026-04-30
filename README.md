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
