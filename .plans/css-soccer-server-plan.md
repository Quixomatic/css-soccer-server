# CSS Soccer Server Docker Image Plan

## Overview

Create a ready-to-go Docker image for CSS Soccer servers that extends the base `css-server` image and includes Soccer Mod, maps, skins, sounds, and default configs baked in.

## Key Directories

| Path | Purpose |
|------|---------|
| `C:\Users\James\Documents\Development\servers\css-soccer` | New soccer server repo (this repo) |
| `C:\Users\James\Documents\Development\servers\css` | Base CSS server repo to mimic structure from |
| `C:\Users\James\Documents\Development\servers\server-mods\soccer-mod` | Soccer Mod source - releases provide plugin + maps |
| `Z:\docker\data\gameserver` | Live server data - reference for working configs |

## Goals

1. **Extend base image** - Use `ghcr.io/quixomatic/css-server:latest` as base
2. **Auto-download from releases** - Pull `soccer-mod-{version}.zip` and `maps-{version}.zip` from GitHub releases
3. **Bake in defaults** - Include default configs, skins, sounds in the image
4. **Volume override pattern** - Mounted volumes override baked-in content (same pattern as base image)
5. **MariaDB integration** - compose.yaml includes database for stats/rankings

## File Structure

```
css-soccer/
├── .github/
│   └── workflows/
│       └── build.yml           # Build and push to ghcr.io
├── .plans/
│   └── css-soccer-server-plan.md
├── content/
│   ├── cfg/                    # Server configs (server.cfg, mapcycle.txt, sm_soccermod/)
│   ├── materials/              # Skins/textures
│   ├── models/                 # Player models
│   └── sound/                  # Sound files
├── scripts/
│   └── entrypoint.sh           # Soccer-specific entrypoint (extends base)
├── Dockerfile
├── compose.yaml                # Run with MariaDB
├── .env.example
├── .gitignore
└── README.md
```

## Tasks

### Phase 1: Soccer Mod Release Updates (soccer-mod repo)
- [x] Update `.github/workflows/release.yml` to create `maps-{version}.zip`
- [x] Update `.github/workflows/release.yml` to create `skins-{version}.zip`
- [x] Add materials/overviews/ (radar files) to soccer-mod
- [ ] Commit and push release workflow changes
- [ ] Create new tag to trigger release with maps.zip and skins.zip

### Phase 2: Repository Setup (css-soccer repo)
- [x] Initialize git repo
- [x] Create Dockerfile (started)
- [ ] Complete Dockerfile with full download logic
- [ ] Create scripts/entrypoint.sh
- [ ] Create compose.yaml with MariaDB service
- [ ] Create .env.example
- [ ] Create .gitignore

### Phase 3: Content Files
- [ ] Copy/create content/cfg/ from live server configs
  - server.cfg, mapcycle.txt, motd.txt
  - sm_soccermod/ configs (main config, mapdefaults, allowed_maps, etc.)
- [ ] Copy content/materials/ (skins textures)
- [ ] Copy content/models/ (player models)
- [ ] Copy content/sound/ (sound files)

### Phase 4: Documentation & CI
- [ ] Create README.md
- [ ] Create .github/workflows/build.yml for GHCR publishing

## Dockerfile Strategy

```dockerfile
ARG BASE_IMAGE=ghcr.io/quixomatic/css-server:latest
FROM ${BASE_IMAGE}

# Download Soccer Mod from GitHub releases
ARG SOCCER_MOD_VERSION=latest
RUN wget "https://github.com/Quixomatic/soccer-mod/releases/${version}/soccer-mod.zip" ...
RUN wget "https://github.com/Quixomatic/soccer-mod/releases/${version}/maps.zip" ...

# Copy default content (can be overridden by volume mounts)
COPY content/cfg/ /home/steam/css/cstrike/cfg/
COPY content/materials/ /home/steam/css/cstrike/materials/
COPY content/models/ /home/steam/css/cstrike/models/
COPY content/sound/ /home/steam/css/cstrike/sound/

# Update defaults backup for volume initialization
RUN cp -r /home/steam/css/cstrike/cfg /home/steam/css-defaults/
RUN cp -r /home/steam/css/cstrike/addons /home/steam/css-defaults/
```

## compose.yaml Strategy

Similar to base css server but with:
- Soccer-specific environment defaults (map, maxplayers, tickrate)
- MariaDB service for stats
- Volume mounts that override baked-in content when needed

## Content Sources

| Content | Source |
|---------|--------|
| Soccer Mod plugin | GitHub releases (soccer-mod-{version}.zip) |
| Maps (.bsp, .nav) | GitHub releases (maps-{version}.zip) |
| Server configs | Z:\docker\data\gameserver\cfg\ |
| sm_soccermod configs | Z:\docker\data\gameserver\cfg\sm_soccermod\ |
| Skins/materials | Z:\docker\data\gameserver\materials\ |
| Models | Z:\docker\data\gameserver\models\ |
| Sounds | Z:\docker\data\gameserver\sound\ |

## Environment Variables

Inherit all from base image, plus soccer-specific defaults:
- `CSS_MAP=ka_soccer_stadium_2019_b1`
- `CSS_MAXPLAYERS=14`
- `CSS_TICKRATE=100`
