{ config, lib, pkgs, ... }:

{
  imports = [ # Include the results of the hardware scan.
    ./hardware-configuration.nix
    <home-manager/nixos>
  ];
  hardware.bluetooth.enable = true;
  hardware.bluetooth.powerOnBoot = true;
  boot.initrd.luks.devices = {
    "luks-main-scsi-2SAMSUNG-part2".device =
      "/dev/disk/by-id/scsi-2SAMSUNG-part2";
  };
  powerManagement.enable = false;

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
  boot.kernelPackages = pkgs.linuxPackages_6_8;

  # Define your hostname.
  networking.hostName = "mekosko";
  # Easiest to use and most distros use this by default.
  networking.networkmanager.enable = true;
  # Provide that for zfs to work.
  networking.hostId = "1ed624d9";

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
    extraGroups = [ "wheel" ]; # Enable ‘sudo’ for the user.
    packages = with pkgs; [ firefox git ];
  };
  home-manager.useUserPackages = true;
  home-manager.useGlobalPkgs = true;

  # Required for sway from home-manager to work.
  security.polkit.enable = true;

  # Define local user configuration.
  home-manager.users.mekosko = {
    programs.git = {
      enable = true;
      userEmail = "mekosko@projectyo.network";
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
    };
    home.stateVersion = "24.05";
  };

  # Enable sway via nixos for things to work properly.
  services.libinput.enable = true;
  programs.sway = {
    enable = true;
    wrapperFeatures.gtk = true;
  };

  # My preferred font for coding.
  fonts.packages = with pkgs; [ cascadia-code ];

  # List packages installed in system profile.
  environment.systemPackages = with pkgs; [
    bluez
    brightnessctl
    grim
    helix
    mako
    nixfmt-classic
    pulsemixer
    slurp
    waybar
    wget
    wl-clipboard
    wofi
  ];
  services.flatpak.enable = true;

  system.stateVersion = "24.05";
}
