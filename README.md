Repository layout (generated template)

├── flake.nix              # Main flake configuration
├── hosts/
│   ├── default/           # Shared host configuration
│   └── framework/         # Host-specific config (Framework laptop)
├── modules/
│   ├── core/              # Core system modules (packages, users)
│   ├── rice/              # Theming (Stylix, colorschemes)
│   └── graphics/          # GPU drivers (AMD, Nvidia, Intel)
├── config/                # Application configs
│   ├── hypr/              # Hyprland, hyprlock, hypridle
│   ├── fish/              # Fish shell
│   ├── kitty/             # Kitty terminal
│   └── nvim/              # Neovim configuration
├── scripts/               # Helper scripts
├── templates/             # Flake templates (Python venv, etc.)
└── docs/

Quick start:

1. Inspect `flake.nix` and fill `hosts/*` and `modules/*`.
2. Rebuild system: `sudo nixos-rebuild switch --flake .#<host>`
3. For home-manager: `home-manager -f . switch` or via flake home-manager outputs.
