# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      #<home-manager/nixos>
    ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.grub.device = "/dev/sda";
  boot.loader.grub.useOSProber = true;
  boot.supportedFilesystems = [ "ntfs" ];
  # networking.hostName = "nixos"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Set your time zone.
  # time.timeZone = "Europe/Amsterdam";
  time.timeZone = "Africa/Cairo";

  # The global useDHCP flag is deprecated, therefore explicitly set to false here.
  # Per-interface useDHCP will be mandatory in the future, so this generated config
  # replicates the default behaviour.
  networking.useDHCP = false;
  networking.interfaces.wlp6s0.useDHCP = true;

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Select internationalisation properties.
  # i18n.defaultLocale = "en_US.UTF-8";
  # console = {
  #   font = "Lat2-Terminus16";
  #   keyMap = "us";
  # };

  # Enable the X11 windowing system.
  services.xserver.enable = true;

  # Enable the GNOME Desktop Environment.
  services.xserver.displayManager.gdm.enable = true;
  services.xserver.desktopManager.gnome.enable = true;
  
  # Configure keymap in X11
  services.xserver.layout = "us";
  services.xserver.xkbOptions = "eurosign:e";

  services.printing.enable = true; #CUPS

  virtualisation.docker.enable = true;

  # sound.enable = true;
  # hardware.pulseaudio.enable = true;

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.alex = {
    isNormalUser = true;
    initialPassword = "pass";
    extraGroups = [ "wheel" "docker" ]; # Enable ‘sudo’ for the user.
  };
  #home-manager.users.alex = { pkgs, ... }: {
  #  home.packages = with pkgs; [ 
  #  ];
  #  #programs.bash.enable = true; 
  #  programs.bash = {
  #  enable = true;
  #  profileExtra = ''
  #    if [ -f "$HOME/.bash-git-prompt/gitprompt.sh" ]; then
  #       GIT_PROMPT_ONLY_IN_REPO=1
  #       source $HOME/.bash-git-prompt/gitprompt.sh
  #    fi
  #  '';
  #};
  #};
  #home-manager.useGlobalPkgs = true;
  nixpkgs.config.allowUnfree = true;  
  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    #vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
    # home
    neovim
    tmux
    git
    xclip #used for ssh on gitlab
    wget
    tldr 
    ntfs3g
    vlc
    direnv
    nix-direnv

    #system
    atool 
    httpie 
    firefox
    brave 
    obsidian
    calibre
    zotero
    #zoom
    discord
    zoom-us
    obs-studio
    nodejs # For coc-nvim

    # haskell.nix
    # https://jkuokkanen109157944.wordpress.com/2020/11/10/creating-a-haskell-development-environment-with-lsp-on-nixos/
    # ghc
    # cabal2nix
    # cabal-install
    # haskellPackages.haskell-language-server
    # haskellPackages.calligraphy #do I need this? 
    # (neovim.override {
    #   configure = {
    #     packages.myPlugins = with pkgs.vimPlugins; {
    #       start = [ coc-nvim ];
    #       opt = [];
    #     };
    #   };
    #  })
    # #finished
    # blas #hmatrix dependencies
    # lapack #hmatrix dependencies
    pre-commit
    yarn
    python

  ];

  environment.variables.EDITOR = "nvim";

  #nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "21.11"; # Did you read the comment?

  environment.pathsToLink = [
    "/share/nix-direnv"
  ];
  # if you also want support for flakes
  nixpkgs.overlays = [
    (self: super: { nix-direnv = super.nix-direnv.override { enableFlakes = true; }; } )
  ];
  #nix = {
  #  binaryCaches          = [ "https://hydra.iohk.io" "https://iohk.cachix.org" ];
  #  binaryCachePublicKeys = [ "hydra.iohk.io:f/Ea+s+dFdN+3Y/G+FDgSq+a5NEWhJGzdjvKNGv0/EQ=" "iohk.cachix.org-1:DpRUyj7h7V830dp/i6Nti+NEO2/nhblbov/8MW7Rqoo=" ];
  #  package = pkgs.nixFlakes; # or versioned attributes like nixVersions.nix_2_8
  #  extraOptions = ''
  #  	keep-outputs = true
  #    keep-derivations = true
  #    experimental-features = nix-command flakes
  #    '';
  # nix options for derivations to persist garbage collection
  #};

}
