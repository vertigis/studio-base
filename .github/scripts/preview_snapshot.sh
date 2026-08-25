#!/usr/bin/env bash
set -euo pipefail

readonly image_repository="ghcr.io/vertigis/studio/base"
readonly package_versions_endpoint="orgs/vertigis/packages/container/studio%2Fbase/versions?per_page=100"
readonly script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
readonly repository_root="$(cd -- "${script_dir}/../.." && pwd)"
readonly output_path="${repository_root}/docs/index.md"

if ! command -v gh >/dev/null 2>&1; then
  echo "GitHub CLI is required. Install it, then run 'gh auth login -s read:packages'." >&2
  exit 1
fi

if ! gh auth status >/dev/null 2>&1; then
  echo "GitHub authentication is required. Run 'gh auth login -s read:packages'." >&2
  exit 1
fi

if ! command -v skopeo >/dev/null 2>&1; then
  echo "skopeo is required to list GHCR tags." >&2
  exit 1
fi

if ! command -v docker >/dev/null 2>&1; then
  echo "Docker with Buildx is required to inspect public GHCR images." >&2
  exit 1
fi

if command -v python >/dev/null 2>&1; then
  readonly python_command="python"
elif command -v python3 >/dev/null 2>&1; then
  readonly python_command="python3"
else
  echo "Python is required to generate the markdown snapshot." >&2
  exit 1
fi

temporary_directory="$(mktemp -d)"
trap 'rm -rf -- "${temporary_directory}"' EXIT

skopeo list-tags "docker://${image_repository}" > "${temporary_directory}/registry-tags.json"
gh api --paginate "${package_versions_endpoint}" > "${temporary_directory}/versions.json"

"${python_command}" -c '
import json
import sys
from pathlib import Path

registry_tags = json.loads(Path(sys.argv[1]).read_text(encoding="utf-8"))
version_tags = [tag for tag in registry_tags["Tags"] if tag.startswith("v")]
version_tags.sort(
    key=lambda tag: (
        tuple(int(part) if part.isdigit() else -1 for part in tag[1:].split("-", 1)[0].split(".")),
        tag,
    ),
    reverse=True,
)
top_tags = version_tags[:5]
if not top_tags:
    raise SystemExit("No version tags were found in ghcr.io/vertigis/studio/base.")

Path(sys.argv[2]).write_text(json.dumps(top_tags), encoding="utf-8")
' "${temporary_directory}/registry-tags.json" "${temporary_directory}/top-tags.json"

if [[ $# -gt 0 ]]; then
  current_tag="$1"
else
  current_tag="$("${python_command}" -c 'import json, sys; print(json.load(open(sys.argv[1], encoding="utf-8"))[0])' "${temporary_directory}/top-tags.json")"
fi

docker buildx imagetools inspect "${image_repository}:${current_tag}" --raw > "${temporary_directory}/manifest.json"

"${python_command}" "${script_dir}/build_snapshot.py" \
  --current-tag "${current_tag}" \
  --top-tags-json "${temporary_directory}/top-tags.json" \
  --manifest-json "${temporary_directory}/manifest.json" \
  --versions-json "${temporary_directory}/versions.json" \
  --output "${output_path}"

cat "${output_path}"
