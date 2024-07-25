{ config, lib, pkgs, ... }:

{
  imports = [ # Include the results of the hardware scan.
    ./hardware-configuration.nix
    <home-manager/nixos>
  ];
  hardware.bluetooth.enable = true;
  hardware.bluetooth.powerOnBoot = true;
  boot.initrd.luks.devices = {
    "luks-main-nvme-HFM256GDJTNG-8310A_CY02N00231100230M-part2".device =
      "/dev/disk/by-id/nvme-HFM256GDJTNG-8310A_CY02N00231100230M-part2";
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
  programs.sway = {
    enable = true;
    wrapperFeatures.gtk = true;
  };
  services.flatpak.enable = true;

  system.stateVersion = "24.05";
}
