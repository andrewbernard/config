#!/bin/bash
set -eu

# Be sure to configure makepkg and pacman before doing all this
#
#     sudo pacman-key -r KEYID
#     sudo pacman-key --lsign-key KEYID
#
# when running `makepkg` you may also need to run this:
#
#     gpg --recv-keys KEYID

noconfirm=--noconfirm
for arg; do
    case ${arg} in
        -i)
            noconfirm=
            ;;
        *)
            echo >&2 "invalid flag: ${arg}"
            echo >&2 "only -i (interactive) is supported"
            exit 1;;
    esac
done

sudo pacman -Sy --needed ${noconfirm} archlinux-keyring
sudo pacman -Suuy ${noconfirm}

inspect_pkg() {
    ls -l
    cat PKGBUILD
    printf '\x1b[33;1m%s\x1b[30;42m%s\x1b[0m\x1b[33;1m%s\x1b[0m\n' \
           "Inspect the package and then type " " exit 0 " " to continue ..."
    "$SHELL" || exit
}

pacman -Q cower >/dev/null 2>&1 || (
    dir=${TMPDIR:-/tmp}/$$
    rm -fr "$dir"
    mkdir "$dir"
    cd "$dir"
    curl -L https://aur.archlinux.org/cgit/aur.git/snapshot/cower.tar.gz | tar xzf -
    cd cower
    inspect_pkg
    gpg --recv-keys 1eb2638ff56c0c53
    sudo pacman -S --needed ${noconfirm} yajl
    makepkg
    sudo pacman -U --needed ${noconfirm} *.pkg.tar.xz
)
pacman -Q pacaur >/dev/null 2>&1 || (
    dir=${TMPDIR:-/tmp}/$$
    rm -fr "$dir"
    mkdir "$dir"
    cd "$dir"
    curl -L https://aur.archlinux.org/cgit/aur.git/snapshot/pacaur.tar.gz | tar xzf -
    cd pacaur
    inspect_pkg
    sudo pacman -S --needed ${noconfirm} expac
    makepkg
    sudo pacman -U --needed ${noconfirm} *.pkg.tar.xz
)

# Note that `xterm` is needed for `xmonad` under the default settings.  Skype
# comes from the `multilib` repository (which allows 32-bit to be run on
# 64-bit).

# libxkbcommon-x11 is wanted by matplotlib;
# python-{numpy,scipy,pandas} are dependencies of python-statsmodels

pkgs=(

    # system
    alsa-utils
    mlocate
    ntfs-3g
    zsh zsh-syntax-highlighting
    # jmtpfs # optional

    # files
    patchutils
    tree
    xz
    zip unzip

    # Pacman
    namcap
    pkgbuild-introspection

    # network
    netctl dialog wpa_actiond wpa_supplicant
    bind-tools
    net-tools
    netcat
    whois
    ntp
    openssh
    rsync
    sshfs

    # miscellaneous
    aspell-en
    bash-completion
    highlight

    # Emacs
    emacs
    emacs-haskell-mode
    emacs-lua-mode
    emacs-python-mode
    auctex

    # terminal applications
    htop
    irssi
    lynx
    mutt

    # development
    git
    #git-annex-bin # not included as the checksum often fails
    doxygen
    gdb
    strace
    valgrind
    jre7-openjdk
    # openblas-lapack # optional

    ## TeX
    texlive-most
    texlive-langgreek

    ## C and C++
    clang

    ## Haskell
    cabal-install
    ghc

    ## Python
    python2
    python3
    python-gobject
    python-google-api-python-client
    python-statsmodels
    python-matplotlib
    libxkbcommon-x11

    # X
    xorg
    xfce4-terminal
    xterm

    ## X utilities
    xbindkeys
    xscreensaver
    feh
    maim slop

    ## XFCE
    xfce4
    xfce4-goodies

    ## Xmonad
    xmonad
    xmonad-contrib
    xmobar
    xorg-xmessage
    dmenu

    ## visual effects
    fvwm
    transset-df
    xcompmgr
    xcursor-themes

    ## graphical applications
    chromium
    evince
    firefox
    gimp
    inkscape
    vlc

    ## graphical utilities
    gnome-keyring
    kdiff3
    rdesktop

    ## VirtualBox (explicitly choose virtualbox-host-modules-arch, otherwise
    ## we might forget to install linux-headers)
    # virtualbox
    # virtualbox-host-modules-arch

    # Yubikey
    # libu2f-host
    # libusb-compat
    # pcsclite
    # yubikey-personalization-gui

    ## fonts (main repo)
    adobe-source-code-pro-fonts
    adobe-source-sans-pro-fonts
    cantarell-fonts
    gnu-free-fonts
    noto-fonts
    noto-fonts-cjk
    noto-fonts-emoji
    ttf-anonymous-pro
    ttf-bitstream-vera
    ttf-dejavu
    ttf-droid
    ttf-fira-sans
    ttf-fira-mono
    ttf-freefont
    ttf-inconsolata
    ttf-liberation
    ttf-linux-libertine-g
    ttf-symbola
    ttf-ubuntu-font-family

    ## fonts (AUR)
    ttf-emojione-color
    ttf-envy-code-r
    ttf-iosevka         # with ligatures (use the “Term” variants for without)
    ttf-iosevka-slab    # see above
    ttf-monaco
    ttf-monoid
    ttf-oxygen-gf
    ttf-roboto
    ttf-roboto-mono
    ttf-share-gf
    # otf-xits # fallback font for Unicode

)
pacaur -S --needed ${noconfirm} "${pkgs[@]}"

sudo systemctl enable ntpd
# sudo systemctl enable pcscd # required?
