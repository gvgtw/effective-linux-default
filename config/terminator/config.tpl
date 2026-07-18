[global_config]
  [[global]]
    inactive_color_offset = 0.8
    handle_size = 4
    enabled_plugins = LaunchpadBugURLHandler, LaunchpadCodeURLHandler, APTURLHandler, CurrDirOpen, TerminatorThemes
[keybindings]
  split_horiz = <Shift><Alt>Down
  split_vert = <Shift><Alt>Right
  switch_to_tab_1 = <Alt>1
  switch_to_tab_2 = <Alt>2
  switch_to_tab_3 = <Alt>3
  switch_to_tab_4 = <Alt>4
  switch_to_tab_5 = <Alt>5
  switch_to_tab_6 = <Alt>6
  switch_to_tab_7 = <Alt>7
  switch_to_tab_8 = <Alt>8
  switch_to_tab_9 = <Alt>9
  switch_to_tab_10 = <Alt>0
[profiles]
  [[default]]
    background_color = "#000000"
    cursor_color = "#bbbbbb"
    background_type = solid
    show_titlebar = False
    use_theme_colors = False
    scrollbar_position = hidden
    scrollback_lines = 2000
    palette = "#000000:#ff5555:#55ff55:#ffff55:#5555ff:#b729d9:#55ff55:#bbbbbb:#555555:#ff5555:#55ff55:#ffff55:#5555ff:#b729d9:#2777ff:#ffffff"
    title_use_system_font = False
    title_font = Sans Regular 9
    title_transmit_fg_color = "#ffffff"
    title_transmit_bg_color = "#ff0000"
    title_receive_fg_color = "#ffffff"
    title_receive_bg_color = "#0000ff"
    title_inactive_fg_color = "#000000"
    title_inactive_bg_color = "#fffdd0"
[layouts]
  [[default]]
    [[[window0]]]
      type = Window
      parent = ""
      order = 0
      position = 120:73
      maximized = False
      fullscreen = False
      size = 1080, 590
    [[[child1]]]
      type = Terminal
      parent = window0
      profile = default
[plugins]
