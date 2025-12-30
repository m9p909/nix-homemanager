curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install
git clone https://github.com/m9p909/nix-homemanager.git ~/.config/home-manager
nix run home-manager/master -- init --switch

