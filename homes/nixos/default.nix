{
  inputs,
  lib,
  config,
  pkgs,
  ...
}: {

  # Add your packages here...
  home.packages = with pkgs; [
    discord
    firefox
    vlc
    nautilus
    vim
    btop
    ghostty

    # Hyprland Specific
    wlr-randr
    pamixer
    brightnessctl
    wbg
    tofi
  ];

  # Git
  programs.git = {
    enable = true;
    settings = {
      user = {
        name = "amikizzy";
        email = "ozrul96@gmail.com";
      };
    };
  };

  # Hyprland
  wayland.windowManager.hyprland = {
    enable = true;
    xwayland.enable = true;
    package = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.hyprland;
    portalPackage = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.xdg-desktop-portal-hyprland;

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
        # Rounding
        rounding = 0;

        # Opacity
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
        "SUPER, E, exec, tofi-run | sh"
        "SUPER, Q, killactive"
        "SUPER, F, fullscreen"

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
        #"waybar"
        "${pkgs.wbg}/bin/wbg -s /home/danny/.config/wallpaper/wallpaper.png"
      ];
    };
};

  # Do not change this!
  home.stateVersion = "25.11";
}
