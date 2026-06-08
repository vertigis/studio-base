#!/usr/bin/env python3
from __future__ import annotations

import argparse
import json
from pathlib import Path


def load_json(path: str) -> object:
    return json.loads(Path(path).read_text(encoding="utf-8"))


def package_url_by_tag(path: str | None) -> dict[str, str]:
    if not path:
        return {}

    payload = load_json(path)
    urls: dict[str, str] = {}

    for version in payload:
        version_id = version.get("id")
        if not version_id:
            continue

        tags = version.get("metadata", {}).get("container", {}).get("tags", [])
        for tag in tags:
            urls[tag] = (
                "https://github.com/vertigis/studio-base/pkgs/container/"
                f"studio%2Fbase/{version_id}?tag={tag}"
            )

    return urls


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--current-tag", required=True)
    parser.add_argument("--top-tags-json", required=True)
    parser.add_argument("--manifest-json", required=True)
    parser.add_argument("--versions-json")
    parser.add_argument("--output", required=True)
    args = parser.parse_args()

    top_tags = [tag for tag in load_json(args.top_tags_json) if isinstance(tag, str) and tag.startswith("v")]
    manifest_payload = load_json(args.manifest_json)
    package_urls = package_url_by_tag(args.versions_json)

    annotations = manifest_payload.get("annotations", {}) if isinstance(manifest_payload, dict) else {}
    component_versions = sorted(
        (
            (name.removeprefix("versions/"), version)
            for name, version in annotations.items()
            if name.startswith("versions/")
        ),
        key=lambda item: item[0],
    )

    lines = [
        "# Tags and Versions",
        "",
        "| Tag | Docs | Package |",
        "| --- | --- | --- |",
    ]

    for tag in top_tags:
        tag_label = f"`{tag}` _(this)_" if tag == args.current_tag else f"`{tag}`"
        docs = f"[docs](?tag={tag})"
        package = package_urls.get(
            tag,
            f"https://github.com/vertigis/studio-base/pkgs/container/studio%2Fbase?tag={tag}",
        )
        lines.append(f"| {tag_label} | {docs} | [package]({package}) |")

    lines.extend(
        [
            "",
            "## Components",
            "",
            "| Component | Version |",
            "| --- | --- |",
        ]
    )

    for component, version in component_versions:
        lines.append(f"| `{component}` | `{version}` |")

    output_path = Path(args.output)
    output_path.parent.mkdir(parents=True, exist_ok=True)
    output_path.write_text("\n".join(lines) + "\n", encoding="utf-8")


if __name__ == "__main__":
    main()
