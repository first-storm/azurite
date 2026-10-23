#!/bin/bash

set -ouex pipefail

archive_url="https://github.com/gaboolic/rime-frost/archive/refs/heads/master.tar.gz"
gram_name="wanxiang-lts-zh-hans"
gram_url="https://github.com/amzxyz/rime-wanxiang-data/releases/download/LTS/${gram_name}.gram"
target_dir="/usr/share/rime-data"
temp_dir="$(mktemp -d)"
source_dir="${temp_dir}/rime-frost"
archive_path="${temp_dir}/rime-frost.tar.gz"

trap 'rm -rf "${temp_dir}"' EXIT

curl -fsSL "${archive_url}" -o "${archive_path}"
mkdir -p "${source_dir}"
tar -xzf "${archive_path}" -C "${source_dir}" --strip-components=1

find "${source_dir}" -maxdepth 1 -type f \( -name '*.yaml' -o -name '*.txt' -o -name '*.gram' \) -print0 |
    while IFS= read -r -d '' source_file; do
        install -Dm644 "${source_file}" "${target_dir}/$(basename "${source_file}")"
    done

for dir_name in cn_dicts cn_dicts_cell cn_dicts_common cn_dicts_wb en_dicts lua opencc; do
    rm -rf "${target_dir:?}/${dir_name}"

    while IFS= read -r -d '' source_file; do
        relative_path="${source_file#"${source_dir}"/}"
        install -Dm644 "${source_file}" "${target_dir}/${relative_path}"
    done < <(find "${source_dir}/${dir_name}" -type f -print0)
done

# Wanxiang language model, used in place of the bundled zh-moqi grammar
curl -fsSL "${gram_url}" -o "${temp_dir}/${gram_name}.gram"
install -Dm644 "${temp_dir}/${gram_name}.gram" "${target_dir}/${gram_name}.gram"

# Parameters follow rime-frost's recommended grammar settings
grep -l '^grammar:' "${target_dir}"/*.schema.yaml |
    while IFS= read -r schema_file; do
        [ -n "$(tail -c1 "${schema_file}")" ] && echo >> "${schema_file}"
        cat >> "${schema_file}" <<EOF

__patch:
  grammar:
    language: ${gram_name}
    collocation_max_length: 5
    collocation_min_length: 2
    collocation_penalty: -14
    non_collocation_penalty: -4
  translator/contextual_suggestions: true
  translator/max_homophones: 4
  translator/max_homographs: 2
EOF
    done
