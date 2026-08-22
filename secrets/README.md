# Shell Secrets Management

This directory holds local environment credentials and API tokens. The secret values are kept outside version control, while this documentation is tracked in `~/dotfiles/secrets/README.md` and symlinked to `~/.secrets/README.md`.

**If you are a coding agent then you MUST ask the user before loading and using keys in this folder**
(`global.sh` keys are already available in the environment and are an exception)

## Directory Setup & Structure

### Setup Instructions
1. Create the secrets directory with restricted permissions:
   ```bash
   mkdir -p ~/.secrets && chmod 700 ~/.secrets
   ```
2. Symlink this README from dotfiles:
   ```bash
   ln -s ~/dotfiles/secrets/README.md ~/.secrets/README.md
   ```
3. Create `global.sh` for baseline environment secrets (sourced on every shell startup):
   ```bash
   touch ~/.secrets/global.sh && chmod 600 ~/.secrets/global.sh
   ```
4. Create individual secret files for on-demand provider keys:
   ```bash
   touch ~/.secrets/openai ~/.secrets/anthropic ~/.secrets/gemini ~/.secrets/opencode
   chmod 600 ~/.secrets/*
   ```

### Directory Tree
```text
~/.secrets/
├── README.md -> ~/dotfiles/secrets/README.md
├── global.sh   # Sourced into every shell via ~/.zshrc
├── openai      # Raw key for OPENAI_API_KEY
├── anthropic   # Raw key for ANTHROPIC_API_KEY
├── gemini      # Raw key for GEMINI_API_KEY
└── opencode    # Raw key for OPENCODE_API_KEY
```

## Files

- **`global.sh`**: Baseline secrets automatically sourced into every shell session via `~/.zshrc`.
- **`openai`**: Raw OpenAI API key (`OPENAI_API_KEY`).
- **`anthropic`**: Raw Anthropic API key (`ANTHROPIC_API_KEY`).
- **`gemini`**: Raw Google / Gemini API key (`GEMINI_API_KEY`).
- **`opencode`**: Raw OpenCode API key (`OPENCODE_API_KEY`).

## Shell Commands (`~/.zshrc`)

### Session-Wide Load / Clear
| Provider | Load Command | Clear Command | Target Variable |
|---|---|---|---|
| OpenAI | `load-openai` | `clear-openai` | `OPENAI_API_KEY` |
| Anthropic | `load-anthropic` | `clear-anthropic` | `ANTHROPIC_API_KEY` |
| Gemini | `load-gemini` | `clear-gemini` | `GEMINI_API_KEY` |
| OpenCode | `load-opencode` | `clear-opencode` | `OPENCODE_API_KEY` |

### Dynamic Scoped Secret Runner
Use `with-secrets` to pass any number of environment variables dynamically to a command subprocess without modifying your parent shell environment:

```bash
# Single secret
with-secrets OPENCODE_API_KEY -- pi

# Multiple secrets
with-secrets OPENCODE_API_KEY GEMINI_API_KEY -- pi list

# Any command
with-secrets ANTHROPIC_API_KEY OPENAI_API_KEY -- aicmd
```

**Resolution logic:** For each requested variable (e.g. `OPENCODE_API_KEY`), `with-secrets` automatically checks `~/.secrets` for:
1. `OPENCODE_API_KEY`
2. `opencode_api_key`
3. `opencode` (stripping `_API_KEY` or `_KEY`)

### Aliases (`~/.zshrc`)
- **`pi`**: Aliased to `with-secrets OPENCODE_API_KEY -- pi`.
