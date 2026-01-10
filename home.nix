{
  config,
  pkgs,
  ...
}:

{
  nixpkgs.config.allowUnfree = true;

  # Home Manager needs a bit of information about you and the paths it should
  # manage.
  home.username = "jackclarke";
  home.homeDirectory = "/Users/jackclarke";

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
      ]
    ))

    # Shell & CLI Enhancements
    pkgs.ripgrep # Fast grep alternative
    pkgs.fd # Fast find alternative
    pkgs.bat # Better cat with syntax highlighting

    # Development Tools
    pkgs.jq # JSON processor for CLI
    pkgs.yq-go # YAML processor
    pkgs.httpie # User-friendly HTTP client
    pkgs.gh # GitHub CLI
    pkgs.gcc # C compiler (for Avante plugin builds)
    pkgs.gnumake # Build tool (for Avante plugin builds)
    pkgs.go_1_25
    pkgs.nodejs_22 # Node.js runtime

    # Git Enhancements
    pkgs.delta # Better git diff viewer
    pkgs.git-absorb # Automatically fixup commits

    # System Utilities
    pkgs.btop # Better process viewer
    pkgs.htop # Process viewer
    pkgs.ncdu # Disk usage analyzer
    pkgs.tree # Directory structure viewer
    pkgs.cloc # Count lines of code
    pkgs.tldr # Simplified man pages
    pkgs.watch # Execute command periodically
    pkgs.parallel # Run commands in parallel

    # Cloud & Infrastructure
    pkgs.kubectl # Kubernetes command-line tool
    pkgs.kubernetes-helm # Kubernetes package manager
    pkgs.k9s # Terminal UI for Kubernetes
    pkgs.terraform # Infrastructure as code
    pkgs.vault # Secrets management

    # Build Tools
    pkgs.maven # Java build tool
    pkgs.gradle # Build automation tool

    # Clojure Ecosystem
    pkgs.clojure # Clojure language
    pkgs.babashka # Native Clojure scripting
    pkgs.leiningen # Clojure build tool

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
    ".claude/commands" = {
      source = ./config/claude/commands;
      recursive = true;
    };
    ".claude/skills" = {
      source = ./config/claude/skills;
      recursive = true;
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
    EDITOR = "nvim";
  };

  programs.neovim = {
    enable = true;
    viAlias = true; # symlink vi → nvim
    vimAlias = true; # symlink vim → nvim
  };

  programs.lazygit = {
    enable = true;
  };

  programs.fzf = {
    enable = true;
    enableZshIntegration = true;
  };

  programs.zoxide = {
    enable = true;
    enableZshIntegration = true;
  };

  programs.direnv = {
    enable = true;
    enableZshIntegration = true;
    nix-direnv.enable = true;
  };

  programs.eza = {
    enable = true;
    enableZshIntegration = true;
    git = true;
    icons = "auto";
  };

  programs.git = {
    enable = true;
    settings = {
      user.name = "m9p909";
      user.email = "jackfulcher09@gmail.com";
      init.defaultBranch = "main";
    };
  };

  programs.delta = {
    enable = true;
    enableGitIntegration = true;
  };

  programs.tmux = {
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
        "terraform"
        "kubectl"
      ];
      theme = "robbyrussell";
    };

    shellAliases = {
      ll = "ls -l";
      update = "home-manager switch";
      avante = ''nvim -c "lua vim.defer_fn(function()require(\"avante.api\").zen_mode()end, 100)"'';
      git-sync = "git fetch --tags --force && git town sync";
      claude-danger = "claude --dangerously-skip-permissions";
      search-code = "rg";
      find-files = "fd";
      sam-enterprise = "sam run examples/webui_auth.yaml examples/sam_basic.yaml examples/logging_config.yaml examples/platform_service.yaml";
      kill-sam = ''lsof -ti:8000,8001 | xargs kill -9 2>/dev/null && echo "Killed processes on ports 8000 and 8001" || echo "No processes found on ports 8000 and 8001"'';
    };
    history.size = 10000;

    initContent = ''
      export PATH="$PATH:$HOME/.local/bin"
      path+=("$HOME/path/")
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

  programs.claude-code = {
    enable = true;
  };

  xdg.configFile."nvim" = {
    source = ./config/nvim;
    recursive = true;
  };

  xdg.configFile."ghostty" = {
    source = ./config/ghostty;
    recursive = true;
  };

  xdg.configFile."lazygit" = {
    source = ./config/lazygit;
    recursive = true;
  };

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}
