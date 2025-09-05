test:
  nvim --headless -c "PlenaryBustedDirectory spec {minimal_init = './tests/minimal_init.lua', pattern = 'view_spec'}"
changelog:
  git cliff -o CHANGELOG.md
