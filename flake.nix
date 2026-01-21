{
  description = "FHS env for micromamba";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs }:
    let 
      system = "x86_64-linux";
      pkgs = import nixpkgs { inherit system; };
      fhs = pkgs.buildFHSEnv {
        name = "fhs-shell";
        targetPkgs = pkgs: with pkgs; [
          coreutils curl gcc jj wget zsh
          micromamba glibc openssl stdenv.cc.cc
        ];

        profile = ''
          export MAMBA_ROOT_PREFIX="$PWD/.mamba"
          export MAMBA_NO_BANNER=1
        '';

        runScript = pkgs.writeShellScript "mamba-setup" ''
          export ZDOTDIR=$(mktemp -d)
          
          cat <<EOF > "$ZDOTDIR/.zshrc"
          [[ -f ~/.zshrc ]] && source ~/.zshrc

          eval "\$(micromamba shell hook --shell zsh)"

          mkdir -p "\$MAMBA_ROOT_PREFIX"

          trap 'rm -rf "$ZDOTDIR"' EXIT
EOF

          exec zsh
        '';
      };
    in
    {
      devShells.${system}.default = fhs.env;
    };
}
