function sops_profile --description "Manage named groups of SOPS-encrypted environment files"
    if test (count $argv) -lt 1
        echo "Usage: sops_profile save NAME FILE... | add NAME FILE... | remove-file NAME FILE... | show NAME | list | remove NAME | run NAME COMMAND [ARG...]" >&2
        return 2
    end

    set -l action $argv[1]
    switch $action
        case save
            if test (count $argv) -lt 3
                echo "Usage: sops_profile save NAME FILE..." >&2
                return 2
            end
            set -l name $argv[2]
            if not string match -rq '^[a-zA-Z0-9_-]+$' -- $name
                echo "Profile names may contain only letters, numbers, _ and -." >&2
                return 2
            end
            set -l files $argv[3..-1]
            for file in $files
                if not test -r "$file"
                    echo "Cannot read SOPS file: $file" >&2
                    return 1
                end
            end
            set -U "sops_profile_$name" $files
            echo "Saved profile '$name' ("(count $files)" encrypted file(s))."

        case add
            if test (count $argv) -lt 3
                echo "Usage: sops_profile add NAME FILE..." >&2
                return 2
            end
            set -l variable "sops_profile_$argv[2]"
            if not set -q $variable
                echo "No such SOPS profile: $argv[2]" >&2
                return 1
            end
            for file in $argv[3..-1]
                if not test -r "$file"
                    echo "Cannot read SOPS file: $file" >&2
                    return 1
                end
            end
            set -l files $$variable
            for file in $argv[3..-1]
                if not contains -- "$file" $files
                    set -a files "$file"
                end
            end
            set -U $variable $files

        case remove-file
            if test (count $argv) -lt 3
                echo "Usage: sops_profile remove-file NAME FILE..." >&2
                return 2
            end
            set -l variable "sops_profile_$argv[2]"
            if not set -q $variable
                echo "No such SOPS profile: $argv[2]" >&2
                return 1
            end
            set -l old_files $$variable
            set -l files
            for old_file in $old_files
                if not contains -- "$old_file" $argv[3..-1]
                    set -a files "$old_file"
                end
            end
            set -U $variable $files

        case show
            if test (count $argv) -ne 2
                echo "Usage: sops_profile show NAME" >&2
                return 2
            end
            set -l variable "sops_profile_$argv[2]"
            if not set -q $variable
                echo "No such SOPS profile: $argv[2]" >&2
                return 1
            end
            printf '%s\\n' $$variable

        case list
            set -l found 0
            for variable in (set --names --universal | string match -r '^sops_profile_[a-zA-Z0-9_-]+')
                echo (string replace -r '^sops_profile_' '' -- $variable)
                set found 1
            end
            if test $found -eq 0
                echo "No SOPS profiles saved."
            end

        case remove
            if test (count $argv) -ne 2
                echo "Usage: sops_profile remove NAME" >&2
                return 2
            end
            set -l variable "sops_profile_$argv[2]"
            if not set -q $variable
                echo "No such SOPS profile: $argv[2]" >&2
                return 1
            end
            set -eU $variable

        case run
            if test (count $argv) -lt 3
                echo "Usage: sops_profile run NAME COMMAND [ARG...]" >&2
                return 2
            end
            set -l variable "sops_profile_$argv[2]"
            if not set -q $variable
                echo "No such SOPS profile: $argv[2]" >&2
                return 1
            end
            if not command -q sops
                echo "sops is not installed or not on PATH." >&2
                return 127
            end
            set -l files $$variable
            for file in $files
                if not test -r "$file"
                    echo "Cannot read SOPS file: $file" >&2
                    return 1
                end
            end
            if not set -q SOPS_AGE_KEY
                if not functions -q age_key
                    echo "SOPS_AGE_KEY is unset; load the age_key function first." >&2
                    return 1
                end
                age_key
                or return 1
            end

            # exec-env accepts a single command string. Escape each nested layer.
            set -l cmd (string join ' ' -- (string escape -- $argv[3..-1]))
            for index in (seq (count $files) -1 1)
                set -l file $files[$index]
                set cmd "sops exec-env "(string escape -- "$file")" "(string escape -- "$cmd")
            end
            eval $cmd

        case '*'
            echo "Unknown action: $action" >&2
            echo "Usage: sops_profile save NAME FILE... | add NAME FILE... | remove-file NAME FILE... | show NAME | list | remove NAME | run NAME COMMAND [ARG...]" >&2
            return 2
    end
end
