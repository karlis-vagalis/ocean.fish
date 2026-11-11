function keepassxc-ssh --description "Load an SSH key attachment from KeePassXC into ssh-agent"
    if test (count $argv) -ne 3
        echo "Usage: keepassxc-ssh KDBX_FILE ENTRY ATTACHMENT" >&2
        return 2
    end

    for dependency in keepassxc-cli ssh-add
        if not command -q $dependency
            echo "Command not found: $dependency" >&2
            return 127
        end
    end

    for attempt in 1 2 3
        printf '\n🔐 Unlocking KeePassXC — attempt %s/3\n' $attempt >&2
        # Buffer only in shell memory so failed exports never reach ssh-add.
        set -l key (command keepassxc-cli attachment-export --stdout $argv)
        set -l export_status $status
        if test $export_status -eq 0
            printf '%s\n' $key | command ssh-add -
            set -l add_status $pipestatus[2]
            set -e key
            if test $add_status -eq 0
                printf '\n✅ SSH key added to ssh-agent.\n' >&2
            else
                printf '\n❌ ssh-add failed; the SSH key was not added.\n' >&2
            end
            return $add_status
        end
        set -e key

        if contains -- $export_status 130 143
            return $export_status
        end
        if test $attempt -lt 3
            printf '\n⚠️  Export failed — check your password and attachment details. Retrying…\n' >&2
        else
            printf '\n❌ Export failed after 3 attempts. No SSH key was added.\n' >&2
            return $export_status
        end
    end
end
