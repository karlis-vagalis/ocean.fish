function age_key --description "Securely prompt for Age key and export it as SOPS_AGE_KEY env variable"
    read --silent --prompt-str "SOPS_AGE_KEY: " input_key

    set --local cleaned_key (string trim -- "$input_key")

    if test -n "$cleaned_key"
        set -gx SOPS_AGE_KEY $cleaned_key
        echo "✅ SOPS_AGE_KEY loaded successfully." >&2
    else
        echo "Error: No key received from stdin." >&2
        return 1
    end
end
