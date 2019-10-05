#!/usr/bin/env bats

function setup() {
    cd "$(dirname ${BATS_TEST_FILENAME})/.."
}

@test 'bin - cldir' {
    for shell in sh ksh mksh dash bash zsh yash; do
        if ! command -v "${shell}" >/dev/null 2>&1; then
            printf 'Skipping %s\n' "${shell}" >&3
            continue
        fi

        run "${shell}" -n 'bin/cldir.sh'
        [ "${status}" -eq '0' ]
        [ "${output}" = '' ]
    done
}