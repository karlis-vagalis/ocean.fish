# Project context

This repository is a Fish shell plugin intended to be installed and managed with [Fisher](https://github.com/jorgebucaran/fisher).

## Plugin conventions

- Put autoloadable Fish functions in `functions/`, with one function per file and a filename matching the function name (for example, `functions/s.fish` defines `s`).
- Keep changes focused on this plugin; validate Fish files with `fish -n functions/*.fish`.
- When changing plugin files during development, refresh the local Fisher installation with `fisher update <repo-path>`.

## Functions

- `age_key` securely prompts for `SOPS_AGE_KEY` interactively and exports it in the current Fish shell. Never print or persist the key.
- `sops_profile` manages named groups of SOPS-encrypted environment files using Fish universal variables:
  - `save NAME FILE...` creates/replaces a profile.
  - `add NAME FILE...` adds files.
  - `show NAME` lists its files.
  - `remove-file NAME FILE...` removes files.
  - `list` and `remove NAME` list/delete profiles.
  - `run NAME COMMAND [ARG...]` runs a command with the profile's decrypted environment.
- `secrets PROFILE [COMMAND [ARG...]]` runs the executable named by the profile by default, or an explicitly supplied command.
- `s` is a short alias for `secrets`.

SOPS decryption must happen in the process tree that launches the target application so its environment is inherited by child processes. Do not write decrypted secrets or age keys to plaintext or temporary files.
