#!/bin/bash

set -ouex pipefail

archive_url="https://github.com/iDvel/rime-ice/archive/refs/heads/main.tar.gz"
target_dir="/usr/share/rime-data"
temp_dir="$(mktemp -d)"
source_dir="${temp_dir}/rime-ice"
archive_path="${temp_dir}/rime-ice.tar.gz"

trap 'rm -rf "${temp_dir}"' EXIT

curl -fsSL "${archive_url}" -o "${archive_path}"
mkdir -p "${source_dir}"
tar -xzf "${archive_path}" -C "${source_dir}" --strip-components=1

find "${source_dir}" -maxdepth 1 -type f \( -name '*.yaml' -o -name 'custom_phrase.txt' \) -print0 |
    while IFS= read -r -d '' source_file; do
        install -Dm644 "${source_file}" "${target_dir}/$(basename "${source_file}")"
    done

for dir_name in cn_dicts en_dicts lua opencc; do
    rm -rf "${target_dir:?}/${dir_name}"

    while IFS= read -r -d '' source_file; do
        relative_path="${source_file#${source_dir}/}"
        install -Dm644 "${source_file}" "${target_dir}/${relative_path}"
    done < <(find "${source_dir}/${dir_name}" -type f -print0)
done
