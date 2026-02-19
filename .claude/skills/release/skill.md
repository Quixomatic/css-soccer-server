# Release

Creates a new versioned release by bumping VERSION, updating CHANGELOG.md, committing, tagging, and pushing.

## Usage

```
/release <version> [description]
```

- `<version>` - The new version number (e.g., `1.1.0`)
- `[description]` - Optional summary of what changed. If omitted, you'll be asked.

## Instructions

1. Read the current `VERSION` file to confirm the current version
2. Read `CHANGELOG.md` to understand the existing format
3. If no description was provided, ask the user what changed in this release
4. Update `VERSION` to the new version number
5. Add a new `## [<version>] - <today's date>` section at the top of the changelog (below the header), with the changes organized into appropriate subsections (Added, Changed, Fixed, Removed, etc.)
6. Stage the changed files: `git add VERSION CHANGELOG.md`
7. Also stage any other uncommitted changes that should be part of this release (check `git status` first and ask the user if unclear)
8. Commit with message: `Release v<version>`
9. Create a git tag: `git tag v<version>`
10. Push the commit and tag: `git push && git push origin v<version>`
11. Confirm the push succeeded and remind the user the GitHub Action will build the Docker image

## Example

```
/release 1.1.0 Add new maps and update Soccer Mod to v1.4.24
```

This will:
- Update VERSION from `1.0.0` to `1.1.0`
- Add a `## [1.1.0]` section to CHANGELOG.md
- Commit as "Release v1.1.0"
- Tag as `v1.1.0`
- Push commit + tag to trigger the build
