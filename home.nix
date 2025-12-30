{ config, pkgs, ... }:

{
  # Home Manager needs a bit of information about you and the paths it should
  # manage.
  home.username = "jack";
  home.homeDirectory = "/home/jack";

  # This value determines the Home Manager release that your configuration is
  # compatible with. This helps avoid breakage when a new Home Manager release
  # introduces backwards incompatible changes.
  #
  # You should not change this value, even if you update Home Manager. If you do
  # want to update the value, then make sure to first check the Home Manager
  # release notes.
  home.stateVersion = "25.11"; # Please read the comment before changing.

  # The home.packages option allows you to install Nix packages into your
  # environment.
  home.packages = [
    # # Adds the 'hello' command to your environment. It prints a friendly
    # # "Hello, world!" when run.
    #pkgs.hello
    pkgs.nil
    pkgs.uv
    pkgs.nixfmt-rfc-style
    pkgs.git-town
    (pkgs.python313.withPackages (
      ps: with ps; [
        requests
        rich
      ]
    ))
    # # It is sometimes useful to fine-tune packages, for example, by applying
    # # overrides. You can do that directly here, just don't forget the
    # # parentheses. Maybe you want to install Nerd Fonts with a limited number of
    # # fonts?
    # (pkgs.nerdfonts.override { fonts = [ "FantasqueSansMono" ]; })

    # # You can also create simple shell scripts directly inside your
    # # configuration. For example, this adds a command 'my-hello' to your
    # # environment:
    # (pkgs.writeShellScriptBin "my-hello" ''
    #   echo "Hello, ${config.home.username}!"
    # '')
  ];

  # Home Manager is pretty good at managing dotfiles. The primary way to manage
  # plain files is through 'home.file'.
  home.file = {
    # # Building this configuration will create a copy of 'dotfiles/screenrc' in
    # # the Nix store. Activating the configuration will then make '~/.screenrc' a
    # # symlink to the Nix store copy.
    # ".screenrc".source = dotfiles/screenrc;

    # # You can also set the file content immediately.
    # ".gradle/gradle.properties".text = ''
    #   org.gradle.console=verbose
    #   org.gradle.daemon.idletimeout=3600000
    # '';
    ".ideavimrc" = {
      source = ./config/.ideavimrc;
    };
    ".tmux.conf" = {
      source = ./config/.tmux.conf;
    };
  };

  # Home Manager can also manage your environment variables through
  # 'home.sessionVariables'. These will be explicitly sourced when using a
  # shell provided by Home Manager. If you don't want to manage your shell
  # through Home Manager then you have to manually source 'hm-session-vars.sh'
  # located at either
  #
  #  ~/.nix-profile/etc/profile.d/hm-session-vars.sh
  #
  # or
  #
  #  ~/.local/state/nix/profiles/profile/etc/profile.d/hm-session-vars.sh
  #
  # or
  #
  #  /etc/profiles/per-user/jack/etc/profile.d/hm-session-vars.sh
  #
  home.sessionVariables = {
    EDITOR = "neovim";
  };

  programs.neovim = {
    enable = true;
    viAlias = true; # symlink vi → nvim
    vimAlias = true; # symlink vim → nvim
  };

  programs.lazygit = {
    enable = true;
  };

  programs.zsh = {
    enable = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
    oh-my-zsh = {
      # "ohMyZsh" without Home Manager
      enable = true;
      plugins = [
        "git"
        "kubectl"
      ];
      theme = "robbyrussell";
    };

    shellAliases = {
      ll = "ls -l";
      update = "home-manager switch";
      docker = "podman";
      avante = ''nvim -c "lua vim.defer_fn(function()require(\"avante.api\").zen_mode()end, 100)"'';
      git-sync = "git town sync";
    };
    history.size = 10000;

    initContent = ''
      export PATH="$PATH:/home/jack/.local/bin"
      path+=('/home/jack/path/')
      alias docker=podman
      ## IMPORTANT
      if [ -f "$HOME/.env" ]; then
          . "$HOME/.env"
      else
          echo "could not find .env" >&2
      fi
      ## IMPORTANT
      PATH=$PATH:$GOROOT/bin:$GOPATH/bin
       # Nix
       if [ -e '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh' ]; then
          . '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh'
       fi
       # End Nix
      		'';
  };

  xdg.configFile."nvim" = {
    source = ./config/nvim; # directory or file in your dotfiles repo
    recursive = true; # copy whole directory tree
  };

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}
