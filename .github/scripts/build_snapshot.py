#!/usr/bin/env python3
from __future__ import annotations

import argparse
import json
from collections import defaultdict
from pathlib import Path


def load_json(path: str) -> object:
    return json.loads(Path(path).read_text(encoding="utf-8"))


def package_metadata_by_tag(path: str | None) -> dict[str, tuple[str, str]]:
    if not path:
        return {}

    payload = load_json(path)
    metadata: dict[str, tuple[str, str]] = {}

    for version in payload:
        version_id = version.get("id")
        if not version_id:
            continue

        created_at = version.get("created_at")
        date = created_at.split("T", 1)[0] if isinstance(created_at, str) else ""
        tags = version.get("metadata", {}).get("container", {}).get("tags", [])
        for tag in tags:
            metadata[tag] = (
                date,
                "https://github.com/vertigis/studio-base/pkgs/container/"
                f"studio%2Fbase/{version_id}?tag={tag}",
            )

    return metadata


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
    package_metadata = package_metadata_by_tag(args.versions_json)

    annotations = manifest_payload.get("annotations", {}) if isinstance(manifest_payload, dict) else {}
    component_versions = sorted(
        (
            (name.removeprefix("versions/"), version)
            for name, version in annotations.items()
            if name.startswith("versions/")
        ),
        key=lambda item: item[0],
    )
    components_by_prefix: dict[str, list[tuple[str, str]]] = defaultdict(list)
    for component, version in component_versions:
        components_by_prefix[component.split("-", 1)[0]].append((component, version))

    grouped_components = {
        prefix: components
        for prefix, components in components_by_prefix.items()
        if len(components) > 1
    }
    ungrouped_components = [
        (component, version)
        for component, version in component_versions
        if component.split("-", 1)[0] not in grouped_components
    ]

    lines = [
        "# Tags and Versions",
        "",
        "| Date | Tag | Docs | Package |",
        "| --- | --- | --- | --- |",
    ]

    for tag in top_tags:
        tag_label = f"`{tag}` _(this)_" if tag == args.current_tag else f"`{tag}`"
        docs = f"[docs](?tag={tag})"
        date, package = package_metadata.get(
            tag,
            (
                "",
                f"https://github.com/vertigis/studio-base/pkgs/container/studio%2Fbase?tag={tag}",
            ),
        )
        lines.append(f"| {date} | {tag_label} | {docs} | [package]({package}) |")

    lines.extend(
        [
            "",
            "## Common",
            "",
            "| Component | Version |",
            "| --- | --- |",
        ]
    )

    for component, version in ungrouped_components:
        lines.append(f"| `{component}` | `{version}` |")

    for prefix, components in sorted(grouped_components.items()):
        principal_version = components[0][1]
        lines.extend(
            [
                "",
                f"### {prefix.title()} `{principal_version}`",
                "",
                "| Component | Version |",
                "| --- | --- |",
            ]
        )
        for component, version in components:
            lines.append(f"| `{component}` | `{version}` |")

    output_path = Path(args.output)
    output_path.parent.mkdir(parents=True, exist_ok=True)
    output_path.write_text("\n".join(lines) + "\n", encoding="utf-8")


if __name__ == "__main__":
    main()
