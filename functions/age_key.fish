function age_key --description "Securely prompt for Age key and export it as SOPS_AGE_KEY env variable"
    if not test -t 0
        echo "age_key must be run from an interactive terminal." >&2
        return 1
    end

    set -l input_key
    read --silent --prompt-str "SOPS_AGE_KEY: " input_key
    or return 1
    if test -z "$input_key"
        echo "No age private key entered." >&2
        return 1
    end

    set -gx SOPS_AGE_KEY "$input_key"
    set -e input_key
    echo "✅ SOPS_AGE_KEY loaded successfully." >&2
end
