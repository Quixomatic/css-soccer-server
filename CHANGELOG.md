# Changelog

All notable changes to the CSS Soccer Server will be documented in this file.

Format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/) and versioning follows [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2026-02-19

### Added
- Docker image extending css-server base with Soccer Mod, maps, and skins
- Automatic Soccer Mod version resolution from GitHub releases
- Docker Compose stack with MariaDB and soccer-stats services
- Soccer-specific entrypoint with volume auto-population for cfg, addons, maps, materials, models, and sound
- Server config, mapcycle, and MOTD templates
- Soccer Mod config files (admins, skins, downloads, GK areas, join/leave sounds, map defaults)
- GitHub Actions CI/CD pipeline with GHCR publishing
- `+hostname` command line parameter for proper hostname display
- Healthcheck using `srcds_linux64`
- Stats URL environment variable for soccer-stats integration
