{
  description = "Command-line client for the Kraken exchange";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs";

  outputs = { self, nixpkgs, }:
    let
      lastModifiedDate =
        self.lastModifiedDate or self.lastModified or "19700101";
      version = builtins.substring 0 8 lastModifiedDate;

      supportedSystems =
        [ "x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin" ];

      forAllSystems = nixpkgs.lib.genAttrs supportedSystems;
      nixpkgsFor = forAllSystems (system: import nixpkgs { inherit system; });

    in {

      packages = forAllSystems (system:
        let pkgs = nixpkgsFor.${system};
        in {

          default = pkgs.python3Packages.buildPythonPackage rec {
            pname = "clikraken";
            name = "clikraken";
            inherit version;

            src = ./.;

            checkPhase =
              "runHook preCheck\n  ${pkgs.python3.interpreter} -m unittest\n  runHook postCheck\n";

            propagatedBuildInputs = with pkgs.python3Packages; [
              requests
              krakenex
              arrow
              tabulate
            ];

            meta = with pkgs.lib; {
              description = "Command-line client for the Kraken exchange";
              homepage = "zertrin.org/projects/clikraken/";
              license = licenses.asl20;
            };
          };
        });

      devShells = forAllSystems (system:
        let pkgs = nixpkgsFor.${system};
        in {
          default = pkgs.mkShell {
            # The Nix packages provided in the environment
            buildInputs = with pkgs.python3Packages; [
              requests
	      krakenex
	      arrow
	      tabulate
	      setuptools 
	    ] ++ [
	      pkgs.pipenv
	    ];
	
	    shellHook = ''
              export PYTHONPATH="$PYTHONPATH:$(pwd)/src" 
	      alias clikraken="python -m clikraken"
	    '';
          };
        });
    };
}
