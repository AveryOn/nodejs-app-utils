# --- NVM ---
export NVM_DIR="$HOME/.nvm"

[ -s "$NVM_DIR/nvm.sh" ] && source "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && source "$NVM_DIR/bash_completion"

# Automatically switch Node.js version using .nvmrc
__nvm_auto_use() {
  local nvmrc_path
  local nvmrc_version
  local signature

  nvmrc_path="$(nvm_find_nvmrc 2>/dev/null)"

  if [ -n "$nvmrc_path" ]; then
    nvmrc_version="$(tr -d '[:space:]' < "$nvmrc_path")"
    signature="$nvmrc_path:$nvmrc_version"
  else
    signature=""
  fi

  # Do nothing until the project or .nvmrc version changes
  if [ "$signature" = "${__NVM_LAST_SIGNATURE:-}" ]; then
    return
  fi

  __NVM_LAST_SIGNATURE="$signature"

  if [ -n "$nvmrc_path" ]; then
    if [ "$(nvm version "$nvmrc_version")" = "N/A" ]; then
      echo "Node.js $nvmrc_version is not installed. Installing..."
      nvm install "$nvmrc_version"
    else
      nvm use "$nvmrc_version"
    fi
  else
    local default_version
    default_version="$(nvm version default 2>/dev/null)"

    if [ "$default_version" != "N/A" ] &&
       [ "$(nvm current)" != "$default_version" ]; then
      nvm use default
    fi
  fi
}

PROMPT_COMMAND="__nvm_auto_use${PROMPT_COMMAND:+;$PROMPT_COMMAND}"
# --- NVM ---