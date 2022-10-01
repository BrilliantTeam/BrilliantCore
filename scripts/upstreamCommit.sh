#!/usr/bin/env bash

# requires curl & jq

# upstreamCommit --paper HASH --pufferfish HASH
# flag: --paper HASH - the commit hash to use for comparing commits between paper (PaperMC/Paper/compare/HASH...HEAD)
# flag: --pufferfish HASH - the commit hash to use for comparing commits between pufferfish (pufferfish-gg/Pufferfish/compare/HASH...HEAD)

function getCommits() {
    curl -H "Accept: application/vnd.github.v3+json" https://api.github.com/repos/"$1"/compare/"$2"...HEAD | jq -r '.commits[] | "'"$1"'@\(.sha[:7]) \(.commit.message | split("\r\n")[0] | split("\n")[0])"'
}

(
set -e
PS1="$"

pufferfishHash="$2"

pufferfish=""
updated=""
logsuffix=""

# Pufferfish updates
if [ -n "$pufferfishHash" ]; then
    pufferfish=$(getCommits "pufferfish-gg/Pufferfish" "$pufferfishHash")

    # Updates found
    if [ -n "$pufferfish" ]; then
        updated="Pufferfish"
        logsuffix="$logsuffix\n\nPufferfish Changes:\n$pufferfish"
    fi
fi


disclaimer="Upstream has released updates that appear to apply and compile correctly"
log="Updated Upstream ($updated)\n\n${disclaimer}${logsuffix}"

echo -e "$log" | git commit -F -

) || exit 1
