{ config, lib, pkgs, ... }:

{
  imports = [ # Include the results of the hardware scan.
    ./hardware-configuration.nix
  ];
  hardware.bluetooth.enable = true;
  hardware.bluetooth.powerOnBoot = true;
  boot.initrd.luks.devices = {
    "luks-main-nvme-HFM256GDJTNG-8310A_CY02N00231100230M-part2".device =
      "/dev/disk/by-id/nvme-HFM256GDJTNG-8310A_CY02N00231100230M-part2";
  };

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

  # List packages installed in system profile.
  environment.systemPackages = with pkgs; [
    bluez
    grim
    helix
    mako
    nixfmt-classic
    slurp
    wl-clipboard
  ];
  programs.sway = {
    enable = true;
    wrapperFeatures.gtk = true;
  };

  system.stateVersion = "24.05";
}
