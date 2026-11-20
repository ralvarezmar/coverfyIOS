#!/usr/bin/env python3
"""Move unpublished changelog entries into a dated release section."""

import argparse
import re
from pathlib import Path


def stamp_changelog(changelog_path, unreleased_heading, version, release_date):
    path = Path(changelog_path)
    if not path.is_file():
        return False

    contents = path.read_text(encoding="utf-8")
    version_pattern = re.escape(version)
    if re.search(
        rf"^## \[{version_pattern}\][^\r\n]*$",
        contents,
        flags=re.MULTILINE,
    ):
        return False

    unpublished_pattern = re.escape(unreleased_heading)
    unpublished = re.search(
        rf"^## \[{unpublished_pattern}\][^\r\n]*$",
        contents,
        flags=re.MULTILINE,
    )
    if unpublished is None:
        return False

    next_heading = re.search(
        r"^## \[[^\]]+\][^\r\n]*$",
        contents[unpublished.end():],
        flags=re.MULTILINE,
    )
    body_end = (
        unpublished.end() + next_heading.start()
        if next_heading is not None
        else len(contents)
    )
    body = contents[unpublished.end():body_end].strip()
    if not body:
        return False

    suffix = contents[body_end:]
    updated = (
        contents[:unpublished.end()]
        + f"\n\n## [{version}] - {release_date}\n\n"
        + body
        + ("\n\n" + suffix if suffix else "\n" if contents.endswith("\n") else "")
    )
    path.write_text(updated, encoding="utf-8")
    return True


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--changelog", required=True)
    parser.add_argument("--unreleased-heading", required=True)
    parser.add_argument("--version", required=True)
    parser.add_argument("--date", required=True, dest="release_date")
    args = parser.parse_args()
    stamp_changelog(
        args.changelog,
        args.unreleased_heading,
        args.version,
        args.release_date,
    )


if __name__ == "__main__":
    main()
