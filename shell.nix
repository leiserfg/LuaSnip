
# save this as shell.nix
{ pkgs ? import <nixpkgs> {}}:

pkgs.mkShell (with pkgs;{
  packages = [
      unzip  
      gperf
      libtermkey
      libuv
      libvterm-neovim
      # This is actually a c library, hence it's not included in neovimLuaEnv,
      # see:
      # https://github.com/luarocks/luarocks/issues/1402#issuecomment-1080616570
      # and it's definition at: pkgs/development/lua-modules/overrides.nix
      lua.pkgs.libluv
      msgpack
      ncurses
      tree-sitter
      unibilium cmake pkg-config libtool libuv autoreconfHook
      ];
})
