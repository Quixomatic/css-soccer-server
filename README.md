# CSS Soccer Server

A ready-to-run Counter-Strike: Source Soccer server with [Soccer Mod (SoMoE-19)](https://github.com/Quixomatic/soccer-mod) pre-installed.

## Features

- Extends the base [css-server](https://github.com/Quixomatic/css-server) image
- Soccer Mod plugin automatically downloaded from releases
- All soccer maps included
- Player skins (Termi, PSL) included
- Soccer-optimized server configuration
- MariaDB for stats and rankings
- Volume mounts for customization

## Quick Start

```bash
# Clone the repo
git clone https://github.com/Quixomatic/css-soccer-server.git
cd css-soccer-server

# Copy and edit environment file
cp .env.example .env
# Edit .env with your settings (especially RCON_PASSWORD and STEAM_GSLT)

# Start the server
docker compose up -d
```

## Configuration

### Environment Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `CSS_HOSTNAME` | CSS Soccer Server | Server name |
| `CSS_PASSWORD` | (empty) | Server password |
| `RCON_PASSWORD` | (empty) | RCON password |
| `CSS_PORT` | 27015 | Server port |
| `CSS_MAXPLAYERS` | 14 | Max players (6v6 + 2 spec) |
| `CSS_TICKRATE` | 100 | Server tickrate |
| `CSS_MAP` | soccer_psl_breezeway_fix | Starting map |
| `CSS_DOWNLOADURL` | (empty) | FastDL URL for skins |
| `STEAM_GSLT` | (empty) | Steam Game Server Login Token |
| `SOCCER_MOD_STATS_URL` | (empty) | Stats website URL for !mystats command |

### Volume Mounts

The image comes with sensible defaults baked in. You can override any content by mounting volumes:

| Volume | Description |
|--------|-------------|
| `./cfg` | Server configs (server.cfg, mapcycle.txt, sm_soccermod/) |
| `./addons` | MetaMod + SourceMod + Soccer Mod |
| `./maps` | Soccer maps |
| `./materials` | Skins textures |
| `./models` | Player models |
| `./sound` | Sound files |
| `./logs` | Server logs |

**Important:** Empty mounted volumes are automatically populated with defaults on first run. Existing files are **never** overwritten when pulling a new image.

## Included Maps

- soccer_psl_breezeway_fix (default)
- ka_soccer_stadium_2019_b1
- ka_soccer_xsl_stadium_b1
- ka_soccer_xsl_stadium_b2
- ka_soccer_titans_club_v3
- ka_soccer_titans_club_v4
- ka_soccer_titans_club_v2_fix
- ka_soccer_xslcentre_fix
- ka_soccer_club_house_b5
- ka_soccer_indoor_2014 (4v4)
- ka_soccer_skillrun_avalon_1vs1
- ka_volleyball_v5

## Database Setup

The compose file includes MariaDB for Soccer Mod stats. Configure the database connection in your SourceMod `databases.cfg`:

```
"soccermod"
{
    "driver"    "mysql"
    "host"      "127.0.0.1"
    "database"  "soccermod"
    "user"      "soccermod"
    "pass"      "soccermodpassword"
}
```

## Building Locally

```bash
docker build -t css-soccer-server .
```

To use a specific Soccer Mod version:

```bash
docker build --build-arg SOCCER_MOD_VERSION=v1.4.12 -t css-soccer-server .
```

## Links

- [Soccer Mod Documentation](https://quixomatic.github.io/soccer-mod/)
- [Soccer Mod Releases](https://github.com/Quixomatic/soccer-mod/releases)
- [Base CSS Server](https://github.com/Quixomatic/css-server)
