function chrome-dev --description "Launch Chrome with remote debugging enabled for MCP"
    set -l chrome_bin google-chrome

    if type -q google-chrome-stable
        set chrome_bin google-chrome-stable
    else if type -q chromium
        set chrome_bin chromium
    end

    $chrome_bin \
        --remote-debugging-address=127.0.0.1 \
        --remote-debugging-port=9222 \
        --user-data-dir="$HOME/.cache/chrome-mcp" \
        --no-first-run \
        --no-default-browser-check \
        >/tmp/chrome-mcp.log 2>&1 &
end
