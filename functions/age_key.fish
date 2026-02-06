function age_key --description "Securely prompt for Age key and export it as SOPS_AGE_KEY env variable"
    read --silent --prompt-str "SOPS_AGE_KEY: " input_key

    set -gx SOPS_AGE_KEY $input_key
    echo "✅ SOPS_AGE_KEY loaded successfully." >&2
end
