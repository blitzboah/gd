{
  description = "low-level gamedev tinkooring";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
  };

  outputs = { self, nixpkgs }:
  let
    system = "x86_64-linux";
    pkgs = nixpkgs.legacyPackages.${system};
  in {
    devShells.${system}.default = pkgs.mkShell {
      packages = with pkgs; [
        zig
        zls
        raylib
        libGL
        xorg.libX11
        pkg-config
      ];

      shellHook = ''
        export C_INCLUDE_PATH=${pkgs.raylib}/include
        export LIBRARY_PATH=${pkgs.raylib}/lib
        export LD_LIBRARY_PATH=${pkgs.raylib}/lib

        echo "   Includes: $C_INCLUDE_PATH"
      '';
    };
  };
}
