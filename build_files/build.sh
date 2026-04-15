#!/bin/bash

set -ouex pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
steps_dir="${script_dir}/steps"

mapfile -t step_scripts < <(find "${steps_dir}" -maxdepth 1 -type f -name '*.sh' | sort)

for step_script in "${step_scripts[@]}"; do
    "${step_script}"
done
