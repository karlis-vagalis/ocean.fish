function secrets --description "Run a command with a named SOPS environment profile"
    if test (count $argv) -lt 1
        echo "Usage: secrets PROFILE [COMMAND [ARG...]]" >&2
        return 2
    end

    set -l profile $argv[1]
    if test (count $argv) -gt 1
        set -l command_name $argv[2]
        set -l command_path (command -s -- $command_name)
        if test -z "$command_path"
            echo "Command not found: $command_name" >&2
            return 127
        end
        sops_profile run $profile $command_path $argv[3..-1]
    else
        set -l command_path (command -s -- $profile)
        if test -z "$command_path"
            echo "No executable named '$profile' found on PATH." >&2
            return 127
        end
        sops_profile run $profile $command_path
    end
end
