{ lib
, rustPlatform
, fetchFromGitHub
, protobuf
, stdenv
, pkg-config
, openssl
, nix-update-script
, Security
}:

rustPlatform.buildRustPackage rec {
  pname = "qdrant";
  version = "1.3.2";

  src = fetchFromGitHub {
    owner = "qdrant";
    repo = "qdrant";
    rev = "refs/tags/v${version}";
    sha256 = "sha256-UKGpbI5XjS0s9Aedos8FX7J1zcbsAgLY1zS3M0DSf9s=";
  };

  cargoLock = {
    lockFile = ./Cargo.lock;
    outputHashes = {
      "quantization-0.1.0" = "sha256-ZPz2vVRA81SZ1xK1d4iiTU54xnr8zGaUzKXIZKGTZOc=";
      "tonic-0.9.2" = "sha256-ZlcDUZy/FhxcgZE7DtYhAubOq8DMSO17T+TCmXar1jE=";
      "wal-0.1.2" = "sha256-sMleBUAZcSnUx7/oQZr9lSDmVHxUjfGaVodvVtFEle0=";
    };
  };

  prePatch = lib.optionalString stdenv.isAarch64 ''
    substituteInPlace .cargo/config.toml \
      --replace "[target.aarch64-unknown-linux-gnu]" "" \
      --replace "linker = \"aarch64-linux-gnu-gcc\"" ""
  '';

  # Needed to get openssl-sys to use pkg-config.
  OPENSSL_NO_VENDOR = 1;

  buildInputs = [ openssl ] ++ lib.optionals stdenv.isDarwin [ Security ];

  nativeBuildInputs = [ protobuf rustPlatform.bindgenHook pkg-config ];

  env.NIX_CFLAGS_COMPILE = lib.optionalString stdenv.isDarwin "-faligned-allocation";

  passthru = {
    updateScript = nix-update-script { };
  };

  meta = with lib; {
    description = "Vector Search Engine for the next generation of AI applications";
    longDescription = ''
      Expects a config file at config/config.yaml with content similar to
      https://github.com/qdrant/qdrant/blob/master/config/config.yaml
    '';
    homepage = "https://github.com/qdrant/qdrant";
    license = licenses.asl20;
    maintainers = with maintainers; [ dit7ya ];
  };
}
