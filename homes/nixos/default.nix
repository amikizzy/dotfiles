{
  inputs,
  lib,
  config,
  pkgs,
  ...
}: {
  nixpkgs = {
    config = {
      # Allow select unfree packages used in home.packages
      allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) [
        "discord"
        "steam"
        "spotify"
      ];
    };
  };

  # Add your packages here...
  home.packages = (with pkgs; [
    nerd-fonts.jetbrains-mono
    discord
    steam
  spotify
    firefox
    vlc
    nautilus
    xfce.thunar
    btop
    ghostty
    vscodium
    neovim
    fastfetch
    pavucontrol
    rofi
      # Terminal tools
      eza
      bat
      ripgrep
      fd
      fzf
      zoxide
      yazi
    playerctl

    # Hyprland Specific
    wlr-randr
    pamixer
    brightnessctl
    wbg
    tofi

    # Screenshot tool (removed flameshot)
  ]) ++ [
    # tpanel (AGS-based panel) — patched to remove Network widget (crashes without WiFi)
    (let
      tpanelBase = inputs.tpanel.packages.x86_64-linux.default;
      patchedSrc = pkgs.runCommand "tpanel-patched-src" {} ''
        cp -r ${tpanelBase}/share $out
        chmod -R +w $out

        # Patch network.tsx: add null check for wifi
        substituteInPlace $out/widgets/bar/network.tsx \
          --replace-fail "const wifi = net.wifi;" "const wifi = net.wifi; if (!wifi) return \"Wired\";"

        # Remove battery import and usage from bar
        substituteInPlace $out/widgets/bar/index.tsx \
          --replace-fail 'import { Battery } from "./battery";' "" \
          --replace-fail "<Battery />" ""

        # Remove Network import and usage from bar
        substituteInPlace $out/widgets/bar/index.tsx \
          --replace-fail 'import { Network } from "./network";' "" \
          --replace-fail "<Network />" ""
      '';
      ags = inputs.tpanel.inputs.ags.packages.x86_64-linux;
      tpanelRebuilt = pkgs.stdenv.mkDerivation {
        name = "tpanel";
        src = patchedSrc;
        nativeBuildInputs = with pkgs; [
          wrapGAppsHook3
          gobject-introspection
          ags.default
        ];
        buildInputs = (with ags; [
          io astal4 hyprland apps battery tray network notifd wireplumber cava
        ]) ++ [ pkgs.gjs pkgs.libadwaita ];
        installPhase = ''
          runHook preInstall
          mkdir -p $out/bin $out/share
          cp -r * $out/share
          ags bundle app.ts $out/bin/tpanel -d "SRC='$out/share'"
          runHook postInstall
        '';
      };
    in pkgs.runCommand "tpanel" {
      nativeBuildInputs = [ pkgs.makeWrapper ];
    } ''
      mkdir -p $out/bin
      cp -r ${tpanelRebuilt}/* $out/
      mv $out/bin/tpanel $out/bin/.tpanel-unwrapped
      makeWrapper $out/bin/.tpanel-unwrapped $out/bin/tpanel \
        --run 'ICONS_DIR="$HOME/.config/tpanel/assets/icons"
          if [ ! -d "$ICONS_DIR" ]; then
            mkdir -p "$ICONS_DIR"
            if [ -d "'"$out"'/share/assets/icons" ]; then
              cp -r "'"$out"'/share/assets/icons/"* "$ICONS_DIR/"
            fi
          fi'
    '')
  ];

  # Set a proper cursor theme to avoid Waybar warnings
  home.pointerCursor = {
    gtk.enable = true;
    x11.enable = true;
    name = "Bibata-Modern-Classic";
    package = pkgs.bibata-cursors;
    size = 24;
  };

  # Ghostty config: Windows-style copy/paste
  xdg.configFile."ghostty/config" = {
    text = ''
      # Copy only consumes Ctrl+C when a selection exists
      keybind = performable:ctrl+c=copy_to_clipboard
      # Paste from system clipboard
      keybind = ctrl+v=paste_from_clipboard
      # Disable default Shift-based copy/paste
      keybind = ctrl+shift+c=unbind
      keybind = ctrl+shift+v=unbind

      # Appearance
      font-family = JetBrainsMono Nerd Font
      font-size = 14
      background-opacity = 0.90
      window-padding-x = 14
      window-padding-y = 12
      cursor-style = block
      scrollback-limit = 67108864

      # Catppuccin-like palette
      palette = 0=#1e1e2e
      palette = 1=#f38ba8
      palette = 2=#a6e3a1
      palette = 3=#f9e2af
      palette = 4=#89b4fa
      palette = 5=#cba6f7
        # Usability
        copy-on-select = false
      palette = 6=#94e2d5
      palette = 7=#bac2de
      palette = 8=#45475a
      palette = 9=#f28fad
      palette = 10=#b9f6ca
      palette = 11=#ffe4a7
      palette = 12=#b4befe
      palette = 13=#f5c2e7
      palette = 14=#89dceb
      palette = 15=#a6adc8
    '';
    force = true;
  };

  # Yazi: Catppuccin-like theme + layout
  xdg.configFile."yazi/yazi.toml" = {
    text = ''
      [manager]
      show_hidden = true
      sort_by = "natural"
      sort_reverse = false
      ratio = [2, 3, 5]

      [preview]
      wrap = "yes"
      tab_size = 2
    '';
    force = true;
  };

  xdg.configFile."yazi/theme.toml" = {
    text = ''
      [ui]
      border = { fg = "#45475a" }
      cursor = { fg = "#1e1e2e", bg = "#b4befe" }
      selection = { fg = "#1e1e2e", bg = "#89b4fa" }

      [syntax]
      comment = "#6c7086"
      constant = "#fab387"
      string = "#a6e3a1"
      number = "#f9e2af"
      boolean = "#f38ba8"
      identifier = "#cba6f7"
      statement = "#89b4fa"
      type = "#94e2d5"
      special = "#f5c2e7"

      [status]
      normal = { fg = "#cdd6f4", bg = "#1e1e2e" }
      select = { fg = "#1e1e2e", bg = "#89b4fa" }
      error  = { fg = "#1e1e2e", bg = "#f38ba8" }
    '';
    force = true;
  };

  # Tmux: enable and keep it simple for the dashboard layout
  programs.tmux = {
    enable = true;
    mouse = true;
    terminal = "tmux-256color";
    escapeTime = 0;
    extraConfig = ''
      set -g status off
      set -g pane-border-style fg=colour238
      set -g pane-active-border-style fg=colour111
      set -g default-terminal "tmux-256color"
      set -ga terminal-overrides ',*:Tc'
    '';
  };

  # Dashboard launcher: Yazi | btop | shell (fastfetch via fish greeting)
  home.file.".local/bin/dash" = {
    text = ''
      #!/usr/bin/env bash
      set -euo pipefail
      SESSION=dash
      if ! tmux has-session -t "$SESSION" 2>/dev/null; then
        tmux new-session -d -s "$SESSION" 'yazi'
        tmux split-window -h -p 50 'btop'
        tmux select-pane -t 1
        tmux split-window -v -p 60 $SHELL
      fi
      exec tmux attach -t "$SESSION"
    '';
    executable = true;
  };

  # Fastfetch: Totoro system summary on shell start
  xdg.configFile."fastfetch/config.jsonc" = {
    text = ''
    {
      "logo": { "source": "Puppy" },
      "modules": [
        "os",
        "host",
        "kernel",
        "uptime",
        "packages",
        "wm",
        "shell",
        "terminal",
        "terminalfont",
        "cpu",
        "gpu",
        "memory",
        "wifi",
        "colors"
      ]
    }
    '';
    force = true;
  };
  xdg.configFile."fastfetch/logo.txt" = {
    text = ''
                     ___   __              
         /¯\    \  \ /  ;             
         \  \    \  v  /              
      /¯¯¯   ¯¯¯¯\\   /  /\           
     ’————————————·\  \ /  ;          
          /¯¯;      \ //  /_          
    _____/  /        ‘/     \         
    \      /,        /  /¯¯¯¯         
     ¯¯/  // \      /__/              
      .  / \  \·————————————.         
       \/  /   \\_____   ___/         
          /  ,  \     \  \            
          \_/ \__\     \_/            
    '';
    force = true;
  };

  # Fish prompt and greeting to display fastfetch
  programs.fish = {
    enable = true;
    functions = {
      fish_greeting = ''
        if status is-interactive
          fastfetch --config ~/.config/fastfetch/config.jsonc ^/dev/null
        end
      '';
      fish_prompt = ''
        set -l status_color (test $status -eq 0; and echo green; or echo red)
        set -l git_info (fish_git_prompt 2>/dev/null)

    # HM programs with shell integrations
    programs.eza.enable = true;
    programs.bat.enable = true;
    programs.fzf = {
      enable = true;
      defaultOptions = [ "--height=40%" "--border" "--info=inline" ];
    };
    programs.zoxide.enable = true;
        set -l cwd (prompt_pwd --full-length-dirs 2)
        set_color blue; echo -n $cwd; set_color normal
        test -n "$git_info"; and echo -n " $git_info"
        set_color $status_color; echo -n ' ❯'; set_color normal; echo -n ' '
      '';
      fish_right_prompt = ''
        set_color yellow; date "+%H:%M"; set_color normal
      '';
    };
  };
  # Git
  programs.git = {
    enable = true;
    userName = "amikizzy";
    userEmail = "ozrul96@gmail.com";
  };

  # Hyprland
  wayland.windowManager.hyprland = {
    enable = true;
    xwayland.enable = true;
    package = pkgs.hyprland;
    systemd.enable = false;

    settings = {
      monitor = [
        #"eDP-1,highrr,auto,1"
      ];

      xwayland = {
        force_zero_scaling = true;
      };

      general = {
        # Master/Stack
        layout = "master";

        # out = in*2
        gaps_in = 2;
        gaps_out = 4;
        border_size = 1;

        "col.active_border" = "rgba(ffffffff)";
        "col.inactive_border" = "rgba(000000ff)";

        resize_on_border = true;
        allow_tearing = false;
      };

      decoration = {
        # Rounding (keep square corners)
        rounding = 0;

        # Base opacity handled via rules; keep defaults here
        active_opacity = 1;
        inactive_opacity = 1;

        shadow = {
          enabled = false;
          range = 4;
          render_power = 3;
          ignore_window = true;
          color = "rgba(20,20,20,0.5)";
        };

        blur = {
          enabled = false;
          size = 4;
          passes = 2;
          ignore_opacity = true;
          new_optimizations = true;
        };
      };

      animations = {
        enabled = true;

        bezier = [
          "snap, 0.2, 0, 0, 1"
        ];

        animation = [
          # Disable top level animations which children inherit.
          "windows, 0"
          "layers, 0"
          "fade, 0"
          "border, 0"
          "borderangle, 0"
          "zoomFactor, 0"

          "workspaces, 1, 2, snap, slide"
        ];
      };

      input = {
        # Mouse/Pointer
        #follow_mouse = 0;
        #mouse_refocus = false;

        # Keyboard
        kb_layout = "gb";

        # Touchpad
        touchpad = {
          tap-to-click = false;
          scroll_factor = 1;
          natural_scroll = true;
          clickfinger_behavior = true;
          middle_button_emulation = true;
          disable_while_typing = true;
        };
      };

      cursor = {
        no_warps = true;
      };

      render = {
        # Direct scanout attempts to reduce lag when
        # there is only one fullscreen application on a screen.
        direct_scanout = 1;
      };

      misc = {
        disable_splash_rendering = true;
        disable_hyprland_logo = true;
        vfr = true;
        vrr = 0;
        # Focus programs that request to be focused, for example
        # pressing a link should switch to the workspace with a browser.
        focus_on_activate = true;
      };

      bind = [
        # Core
        "SUPER, Return, exec, ghostty"
        "SUPER, E, exec, bash /home/danny/dotfiles/scripts/appmenu.sh"
        "SUPER, Q, killactive"
        "SUPER, F, fullscreen"

        # Screenshot keybind removed (previously SUPER+SHIFT+S for flameshot)

        # Workspace Navigation
        "SUPER, 1, workspace, 1"
        "SUPER, 2, workspace, 2"
        "SUPER, 3, workspace, 3"
        "SUPER, 4, workspace, 4"
        "SUPER, 5, workspace, 5"
        "SUPER, 6, workspace, 6"
        "SUPER, 7, workspace, 7"
        "SUPER, 8, workspace, 8"
        "SUPER, 9, workspace, 9"
        "SUPER, 0, workspace, 10"

        # Workspace Manipulation
        "SUPER SHIFT, 1, movetoworkspace, 1"
        "SUPER SHIFT, 2, movetoworkspace, 2"
        "SUPER SHIFT, 3, movetoworkspace, 3"
        "SUPER SHIFT, 4, movetoworkspace, 4"
        "SUPER SHIFT, 5, movetoworkspace, 5"
        "SUPER SHIFT, 6, movetoworkspace, 6"
        "SUPER SHIFT, 7, movetoworkspace, 7"
        "SUPER SHIFT, 8, movetoworkspace, 8"
        "SUPER SHIFT, 9, movetoworkspace, 9"
        "SUPER SHIFT, 0, movetoworkspace, 10"

        # Window Manipulation
        "SUPER SHIFT, left, layoutmsg, mfact -0.05"
        "SUPER SHIFT, right, layoutmsg, mfact +0.05"

        "SUPER SHIFT, F, togglefloating"

        # Quit
        "SUPER SHIFT, Q, exit"
      ];

      # Removed global transparency/blur rules (reverted per user request)

      # Will repeat when held.
      binde = [
        # Volume
        ",XF86AudioRaiseVolume, exec, ${pkgs.pamixer}/bin/pamixer -i 2"
        ",XF86AudioLowerVolume, exec, ${pkgs.pamixer}/bin/pamixer -d 2"
        ",XF86AudioMute, exec, ${pkgs.pamixer}/bin/pamixer -t"
        ",XF86AudioMicMute, exec, ${pkgs.pamixer}/bin/pamixer --default-source -t"

        # Brightness
        ",XF86MonBrightnessUp, exec, ${pkgs.brightnessctl}/bin/brightnessctl set 1%+"
        ",XF86MonBrightnessDown, exec, ${pkgs.brightnessctl}/bin/brightnessctl set 1%-"

        # Backlight
        "SUPER, XF86MonBrightnessUp, exec, ${pkgs.brightnessctl}/bin/brightnessctl --class leds --device kbd_backlight set 1%+"
        "SUPER, XF86MonBrightnessDown, exec, ${pkgs.brightnessctl}/bin/brightnessctl --class leds --device kbd_backlight set 1%-"
      ];

      bindm = [
        "SUPER, mouse:273, resizewindow"
        "SUPER, mouse:272, movewindow"
      ];

      exec-once = [
        "${pkgs.wbg}/bin/wbg -s /home/danny/.config/wallpaper/wallpaper.png"
        "tpanel"
      ];
    };
};



  # Start user services on login for reliable autostart
  systemd.user.startServices = true;

  # Home Manager release compatibility version
  home.stateVersion = "24.11";
}
