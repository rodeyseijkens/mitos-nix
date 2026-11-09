# Mitos for NixOS

Unofficial Nix package for [Mitos](https://mitos.computer) - a fast and minimal modal text editor, forked from [Helix](https://github.com/helix-editor/helix).

The package uses the official prebuilt Linux release archive from GitHub, so no Rust toolchain or grammar compilation is required. It bundles the `ms` executable together with its `runtime/` directory (themes, queries, dictionaries, and compiled grammars), shell completions, a desktop entry, and an icon.

## Installation

### NixOS (Recommended)

Add the flake input and import the module:

```nix
{
  inputs = {
    mitos = {
      url = "github:rodeyseijkens/mitos-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, mitos, ... }: {
    nixosConfigurations.myhost = nixpkgs.lib.nixosSystem {
      modules = [
        mitos.nixosModules.default
        # ... your other modules
      ];
    };
  };
}
```

The module adds `mitos` (the `ms` command) to `environment.systemPackages`.

### Home Manager

```nix
{
  inputs = {
    mitos = {
      url = "github:rodeyseijkens/mitos-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, mitos, ... }: {
    homeConfigurations.myhost = home-manager.lib.homeManagerConfiguration {
      modules = [
        mitos.homeManagerModules.default
        {
          programs.mitos.enable = true;
          # programs.mitos.package = mitos.packages.x86_64-linux.default;
        }
      ];
    };
  };
}
```

Or add the package directly:

```nix
home.packages = [
  mitos.packages.x86_64-linux.default
];
```

### Direct Run (no install)

```bash
nix run github:rodeyseijkens/mitos-nix -- --version
```

### Imperative Install

```bash
nix profile install github:rodeyseijkens/mitos-nix
```

### Overlay

```nix
{
  inputs.mitos.url = "github:rodeyseijkens/mitos-nix";
  inputs.mitos.inputs.nixpkgs.follows = "nixpkgs";

  outputs = { nixpkgs, mitos, ... }: {
    nixpkgs.overlays = [ mitos.overlays.default ];
    # pkgs.mitos is now available
  };
}
```

## Usage

The executable is called `ms`:

```bash
ms path/to/file
ms --health
```

The wrapper sets `MITOS_RUNTIME` to the bundled runtime. A runtime under
`$XDG_CONFIG_HOME/mitos/runtime` still takes precedence, so user overrides keep working.

## Supported Systems

- `x86_64-linux`
- `aarch64-linux`

## Update Package

Maintainers can update to the latest version:

```bash
./update.sh
```

## License

The Nix packaging is MIT. Mitos itself is licensed under MPL-2.0.

## Links

- [Mitos](https://mitos.computer)
- [Mitos GitHub](https://github.com/mitos-editor/mitos)
