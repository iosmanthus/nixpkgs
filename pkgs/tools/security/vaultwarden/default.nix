{ lib, stdenv, callPackage, rustPlatform, fetchFromGitHub, nixosTests
, pkg-config, openssl
, libiconv, Security, CoreServices, SystemConfiguration
, dbBackend ? "sqlite", libmysqlclient, postgresql }:

let
  webvault = callPackage ./webvault.nix {};
in

rustPlatform.buildRustPackage rec {
  pname = "vaultwarden";
  version = "unstable-2024-09-12";

  src = fetchFromGitHub {
    owner = "dani-garcia";
    repo = "vaultwarden";
    rev = "25d99e3506a01b7d031d12f51d69a3cae3149065";
    hash = "sha256-m6aluk/pHj42fKwcASoy8dagSxRw7WQjCq9FPn8M9Z8=";
  };

  cargoHash = "sha256-O2wgBilVW65XckhCJlEohyorvR0LPCdM1oaYMbhibHs=";

  # used for "Server Installed" version in admin panel
  env.VW_VERSION = version;

  nativeBuildInputs = [ pkg-config ];
  buildInputs = [ openssl ]
    ++ lib.optionals stdenv.isDarwin [ libiconv Security CoreServices SystemConfiguration ]
    ++ lib.optional (dbBackend == "mysql") libmysqlclient
    ++ lib.optional (dbBackend == "postgresql") postgresql;

  buildFeatures = dbBackend;

  passthru = {
    inherit webvault;
    tests = nixosTests.vaultwarden;
    updateScript = callPackage ./update.nix {};
  };

  meta = with lib; {
    description = "Unofficial Bitwarden compatible server written in Rust";
    homepage = "https://github.com/dani-garcia/vaultwarden";
    changelog = "https://github.com/dani-garcia/vaultwarden/releases/tag/${version}";
    license = licenses.agpl3Only;
    maintainers = with maintainers; [ dotlambda SuperSandro2000 ];
    mainProgram = "vaultwarden";
  };
}
