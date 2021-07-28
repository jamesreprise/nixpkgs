{ stdenv
, fetchFromGitHub
, lib
, autoPatchelfHook
, cmake
, llvmPackages_latest
, xxHash
, zlib
, openssl
}:

stdenv.mkDerivation rec {
  pname = "mold";
  version = "0.9.3";

  src = fetchFromGitHub {
    owner = "rui314";
    repo = pname;
    rev = "v${version}";
    sha256 = "sha256:1z9i8nvdl9h0zydh1gd9244q96n9x1gh5y90m71bghnh7nws0zmd";
  };

  buildInputs = [ zlib openssl ];
  nativeBuildInputs = [ autoPatchelfHook cmake xxHash ];

  dontUseCmakeConfigure = true;
  EXTRA_LDFLAGS = "-fuse-ld=${llvmPackages_latest.lld}/bin/ld.lld";
  LTO = 1;
  makeFlags = [ "PREFIX=${placeholder "out"}" ];

  meta = with lib; {
    description = "A high performance drop-in replacement for existing unix linkers";
    homepage = "https://github.com/rui314/mold";
    license = lib.licenses.agpl3Plus;
    maintainers = with maintainers; [ nitsky ];
    broken = stdenv.isAarch64;
  };
}
