#!/bin/sh
# Install the sprinx-skills skills for OpenAI Codex.
#
# Codex discovers skills as <skills-dir>/<skill-name>/SKILL.md. This script points
# such a directory at the skills in this repository - by symlink, so a `git pull`
# updates the installed skills, or by copy where symlinks are not an option.
#
#   ./scripts/install-codex.sh                     link into ~/.agents/skills
#   ./scripts/install-codex.sh --copy              copy instead of link
#   ./scripts/install-codex.sh --target DIR        install somewhere else
#   ./scripts/install-codex.sh --uninstall         remove what this script installed
#
# Older Codex releases read ~/.codex/skills instead of ~/.agents/skills; pass that
# path with --target if `$skill-name` does not find the skills after installing.

set -eu

target="${SPRINX_SKILLS_TARGET:-$HOME/.agents/skills}"
mode=link
action=install

usage() {
    awk 'NR > 1 && !/^#/ { exit } NR > 1 { sub(/^# ?/, ""); print }' "$0"
}

while [ $# -gt 0 ]; do
    case "$1" in
        --target) [ $# -ge 2 ] || { echo "--target needs a directory" >&2; exit 2; }
                  target="$2"; shift 2 ;;
        --target=*) target="${1#--target=}"; shift ;;
        --copy) mode=copy; shift ;;
        --uninstall) action=uninstall; shift ;;
        -h|--help) usage; exit 0 ;;
        *) echo "unknown option: $1" >&2; usage >&2; exit 2 ;;
    esac
done

repo=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
src="$repo/skills"

[ -d "$src" ] || { echo "no skills/ directory in $repo" >&2; exit 1; }

installed=0
skipped=0

for skill in "$src"/*/; do
    [ -f "$skill/SKILL.md" ] || continue
    name=$(basename "$skill")
    dest="$target/$name"

    if [ "$action" = uninstall ]; then
        if [ -L "$dest" ]; then
            rm "$dest"; installed=$((installed + 1)); echo "removed  $dest"
        elif [ -d "$dest" ] && [ -f "$dest/.sprinx-skills" ]; then
            rm -rf "$dest"; installed=$((installed + 1)); echo "removed  $dest"
        elif [ -e "$dest" ]; then
            skipped=$((skipped + 1)); echo "kept     $dest (not installed by this script)"
        fi
        continue
    fi

    mkdir -p "$target"

    # Replace only what this script itself installed; never clobber a real
    # directory somebody else put there.
    if [ -L "$dest" ]; then
        rm "$dest"
    elif [ -d "$dest" ] && [ -f "$dest/.sprinx-skills" ]; then
        rm -rf "$dest"
    elif [ -e "$dest" ]; then
        skipped=$((skipped + 1))
        echo "skipped  $dest already exists and was not installed by this script" >&2
        continue
    fi

    if [ "$mode" = link ]; then
        ln -s "${skill%/}" "$dest"
        echo "linked   $dest -> ${skill%/}"
    else
        cp -R "${skill%/}" "$dest"
        : > "$dest/.sprinx-skills"
        echo "copied   $dest"
    fi
    installed=$((installed + 1))
done

if [ "$action" = uninstall ]; then
    echo "removed $installed skill(s) from $target"
    [ "$skipped" -eq 0 ] || echo "kept $skipped director(ies) this script did not install"
    exit 0
fi

echo
echo "installed $installed skill(s) into $target"
[ "$skipped" -eq 0 ] || echo "skipped $skipped - remove them by hand and run again" >&2
echo "In Codex, run one with \$sx-brainstorming (or let it match on description)."
