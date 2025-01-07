{ config, lib, pkgs, ... }:

{
  imports = [ # Include the results of the hardware scan.
    ./hardware-configuration.nix
    <home-manager/nixos>
  ];
  hardware.bluetooth.enable = true;
  services.blueman.enable = true;

  hardware.bluetooth.powerOnBoot = true;
  powerManagement.enable = false;

  # Things for development
  networking.hosts = { "fd00:5050:5050:5050:5050::40" = [ "stokejo" ]; };
  virtualisation.docker.enable = true;

  # Suspend is not working properly on my machine.
  systemd.targets.hybrid-sleep.enable = false;
  systemd.targets.suspend.enable = false;
  systemd.targets.hibernate.enable = false;
  systemd.targets.sleep.enable = false;

  # Power off at 10% charge to save battery.
  services.upower = {
    enable = true;
    criticalPowerAction = "PowerOff";
    percentageAction = 10;
    percentageCritical = 15;
    percentageLow = 20;
  };

  # Display manager required for upower to work.
  services.displayManager.enable = true;
  services.xserver.displayManager.gdm.enable = true;

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  # Use newer kernel for keyboard to work.
  boot.kernelPackages = pkgs.linuxPackages_6_12;

  # Define your hostname.
  networking.hostName = "mekosko";
  # Easiest to use and most distros use this by default.
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "Asia/Yekaterinburg";

  # Enable sound.
  services.pipewire = {
    enable = true;
    pulse.enable = true;
  };

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.mekosko = {
    isNormalUser = true;
    extraGroups = [ "docker" "wheel" ]; # Enable sudo for the user.
    packages = with pkgs; [ firefox firefox-devedition git ];
  };
  home-manager.useUserPackages = true;
  home-manager.useGlobalPkgs = true;

  # Required for sway from home-manager to work.
  security.polkit.enable = true;

  # Define local user configuration.
  home-manager.users.mekosko = {
    programs.git = {
      enable = true;
      userEmail = "mekosko@morojenoye.com";
      userName = "mekosko";
    };
    programs.foot.enable = true;
    programs.foot.settings = {
      main = {
        font = "CascadiaMono:size=19";
        term = "xterm-256color";
      };
    };
    wayland.windowManager.sway = {
      enable = true;
      config.modifier = "Mod4";
      config.keybindings = lib.mkOptionDefault {
        "Mod4+Print" = ''exec grim -g "$(slurp -d)" - | wl-copy -t image/png'';
      };
    };
    wayland.windowManager.sway.config.input = {
      "*" = {
        xkb_options = "grp:alt_shift_toggle";
        xkb_layout = "us,ru";
        xkb_variant = ",";
      };
      "type:touchpad" = {
        natural_scroll = "enabled";
        tap = "enabled";
      };
      "type:pointer".pointer_accel = "-0.7";
    };
    wayland.windowManager.sway.config.bars = [{ command = "waybar"; }];
    home.file.".config/waybar/config".text = builtins.toJSON {
      position = "top";
      height = 30;

      modules-left = [ "sway/workspaces" ];
      layer = "top";

      memory = { format = "RAM: {used} / {total}"; };
      pulseaudio.format = "AUX: {volume}%";

      network = { format = "{ifname}: {ipaddr}"; };
      clock = { format = "{:%e %b %Y %H:%M}"; };

      battery.format = "BAT: {capacity}%";
      cpu = { format = "CPU: {usage}%"; };

      modules-right = [ # =
        "network"
        "cpu"
        "memory"
        "battery"
        "pulseaudio"
        "tray"
        "clock"
      ];
    };
    programs.waybar.enable = true;
    home.stateVersion = "24.11";
  };

  # Enable sway via nixos for things to work properly.
  services.libinput.enable = true;
  programs.sway = {
    enable = true;
    wrapperFeatures.gtk = true;
  };

  # Enable UWSM to make better environment.
  programs.uwsm.waylandCompositors = {
    sway = {
      prettyName = "Sway";
      comment = "Sway compositor managed by UWSM";
      binPath = "/run/current-system/sw/bin/sway";
    };
  };
  programs.uwsm.enable = true;

  # Setup unfree packages and steam.
  nixpkgs.config.allowUnfree = true;
  programs.steam.enable = true;

  # My preferred font for coding.
  fonts.packages = with pkgs; [ cascadia-code ];

  # List packages installed in system profile.
  environment.systemPackages = with pkgs; [
    bluez
    brightnessctl
    grim
    helix
    htop
    libsecret
    mako
    networkmanager-openvpn
    nixfmt-classic
    pulsemixer
    qemu_full
    rustup
    slurp
    way-displays
    waybar
    wget
    wireguard-tools
    wl-clipboard
    wofi
  ];
  services.flatpak.enable = true;
  xdg.portal.enable = true;

  system.stateVersion = "24.11";
}
