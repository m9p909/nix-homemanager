{ pkgs, config, ... }:
let
  ghosttyTerminfo =
    pkgs.runCommand "ghostty-terminfo"
      {
        nativeBuildInputs = [ pkgs.ncurses ];
      }
      ''
        mkdir -p "$out/share/terminfo"
        tic -x -o "$out/share/terminfo" ${./../config/terminfo/ghostty.terminfo}
      '';

  emacsClientApp =
    pkgs.runCommand "emacs-client-app"
      {
        meta.mainProgram = "emacsclient";
      }
      ''
        app="$out/Applications/Emacs Client.app/Contents"
        mkdir -p "$app/MacOS" "$app/Resources"

        cp ${pkgs.emacs}/Applications/Emacs.app/Contents/Resources/Emacs.icns \
          "$app/Resources/Emacs.icns"

        cat > "$app/Info.plist" <<'EOF'
        <?xml version="1.0" encoding="UTF-8"?>
        <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
        <plist version="1.0">
        <dict>
          <key>CFBundleName</key>
          <string>Emacs Client</string>
          <key>CFBundleDisplayName</key>
          <string>Emacs Client</string>
          <key>CFBundleIdentifier</key>
          <string>org.gnu.emacs-client</string>
          <key>CFBundleExecutable</key>
          <string>emacs-client</string>
          <key>CFBundleIconFile</key>
          <string>Emacs</string>
          <key>CFBundlePackageType</key>
          <string>APPL</string>
        </dict>
        </plist>
        EOF

        cat > "$app/MacOS/emacs-client" <<EOF
        #!/bin/sh
        exec ${pkgs.emacs}/bin/emacsclient -c -n -a "" "\$@"
        EOF
        chmod +x "$app/MacOS/emacs-client"
      '';
in
{
  home.packages = [
    emacsClientApp
    ghosttyTerminfo
  ];

  launchd.agents.emacs-daemon = {
    enable = true;
    config = {
      ProgramArguments = [
        "${pkgs.emacs}/bin/emacs"
        "--fg-daemon"
      ];
      EnvironmentVariables = {
        TERMINFO_DIRS = "${ghosttyTerminfo}/share/terminfo:/usr/share/terminfo";
      };
      RunAtLoad = true;
      KeepAlive = true;
      StandardOutPath = "${config.home.homeDirectory}/Library/Logs/emacs-daemon.log";
      StandardErrorPath = "${config.home.homeDirectory}/Library/Logs/emacs-daemon.log";
    };
  };
}
