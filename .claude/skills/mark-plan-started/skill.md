# Mark Plan Started

Marks a plan file as in-progress by renaming it from `_planname.md` to `!planname.md`.

## Usage

```
/mark-plan-started <plan-name>
```

## Instructions

1. Look for a file matching `_<plan-name>.md` in the `.plans` folder
2. Rename it to `!<plan-name>.md`
3. If the file doesn't exist, list available plans in `.plans` folder

## Example

```
/mark-plan-started volume-init-refactor
```

This renames `.plans/_volume-init-refactor.md` to `.plans/!volume-init-refactor.md`
