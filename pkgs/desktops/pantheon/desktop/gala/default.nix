{ lib
, stdenv
, fetchFromGitHub
, fetchpatch
, nix-update-script
, pkg-config
, meson
, python3
, ninja
, vala
, desktop-file-utils
, gettext
, libxml2
, gtk3
, granite
, libgee
, bamf
, libcanberra-gtk3
, gnome-desktop
, mutter
, clutter
, gnome-settings-daemon
, wrapGAppsHook
, gexiv2
}:

stdenv.mkDerivation rec {
  pname = "gala";
  version = "7.0.0";

  src = fetchFromGitHub {
    owner = "elementary";
    repo = pname;
    rev = version;
    sha256 = "sha256-S3X9ZyTCC9+4TuVwhbRV6ZK8JodIddPsk/Ghj6da4sI=";
  };

  patches = [
    # We look for plugins in `/run/current-system/sw/lib/` because
    # there are multiple plugin providers (e.g. gala and wingpanel).
    ./plugins-dir.patch

    # Fix multitasking shadows
    # https://github.com/elementary/gala/pull/1503
    (fetchpatch {
      url = "https://github.com/elementary/gala/commit/223fdb0135a1f046128e9906e87f40a21cca8fa6.patch";
      sha256 = "sha256-OXiNOk5pdrijuqBWrAUfoVZOEc186lS30A6wTl5Js48=";
    })

    # Fix no-respond app automatically closes after inactivity
    # https://github.com/elementary/gala/pull/1515
    (fetchpatch {
      url = "https://github.com/elementary/gala/commit/4bf55e76dbee7c6fd03f445c87c93c355ca83561.patch";
      sha256 = "sha256-8GMyXeIA/bILGVdf3SQWJMzqHQUFkJlTH8g7fdn23CU=";
    })

    # Fix wrong confirm_display_change() timeout
    # https://github.com/elementary/gala/pull/1516
    (fetchpatch {
      url = "https://github.com/elementary/gala/commit/05dceba10dc25bee3df1f74defad8ef055a8ea3e.patch";
      sha256 = "sha256-vB4OHeonKduyXBRuT03b+boQv6p6Z6IsLP6OtGtgDaY=";
    })
  ];

  nativeBuildInputs = [
    desktop-file-utils
    gettext
    libxml2
    meson
    ninja
    pkg-config
    python3
    vala
    wrapGAppsHook
  ];

  buildInputs = [
    bamf
    clutter
    gnome-settings-daemon
    gexiv2
    gnome-desktop
    granite
    gtk3
    libcanberra-gtk3
    libgee
    mutter
  ];

  mesonFlags = [
    # TODO: enable this and remove --builtin flag from session-settings
    # https://github.com/NixOS/nixpkgs/pull/140429
    "-Dsystemd=false"
  ];

  postPatch = ''
    chmod +x build-aux/meson/post_install.py
    patchShebangs build-aux/meson/post_install.py
  '';

  passthru = {
    updateScript = nix-update-script { };
  };

  meta = with lib; {
    description = "A window & compositing manager based on mutter and designed by elementary for use with Pantheon";
    homepage = "https://github.com/elementary/gala";
    license = licenses.gpl3Plus;
    platforms = platforms.linux;
    maintainers = teams.pantheon.members;
    mainProgram = "gala";
  };
}
