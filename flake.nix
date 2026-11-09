{
  description = "Mitos - a fast and minimal modal text editor";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs = {self, nixpkgs}: let
    systems = ["x86_64-linux" "aarch64-linux"];
    forAllSystems = nixpkgs.lib.genAttrs systems;
    pkgsFor = system:
      import nixpkgs {
        inherit system;
      };
  in {
    packages = forAllSystems (system: {
      default = self.packages.${system}.mitos;
      mitos = (pkgsFor system).callPackage ./package.nix {};
    });

    overlays.default = final: _prev: {
      mitos = final.callPackage ./package.nix {};
    };

    overlays.mitos = self.overlays.default;

    nixosModules.default = {pkgs, ...}: {
      environment.systemPackages = [
        (pkgs.callPackage ./package.nix {})
      ];
    };

    nixosModules.mitos = self.nixosModules.default;

    homeManagerModules.default = {
      config,
      lib,
      pkgs,
      ...
    }: let
      cfg = config.programs.mitos;
    in {
      options.programs.mitos = {
        enable = lib.mkEnableOption "Mitos text editor";

        package = lib.mkOption {
          type = lib.types.package;
          default = self.packages.${pkgs.stdenv.hostPlatform.system}.default;
          defaultText = lib.literalExpression "mitos.packages.\${pkgs.stdenv.hostPlatform.system}.default";
        };
      };

      config = lib.mkIf cfg.enable {
        home.packages = [cfg.package];
      };
    };

    homeManagerModules.mitos = self.homeManagerModules.default;
  };
}
