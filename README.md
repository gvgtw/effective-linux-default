# effective-kali-default
Default Configuration settings for fresh kali install

### Steps for default installation
---
1. Install pimpmykali
2. Set SUDO permissions for user kali
3. Install and setup Terminator
4. Change Terminal prompt
5. Other Environment Customizations


#### Install pimpmykali
---
```
sudo apt-get update
```
```
git clone https://github.com/Dewalt-arch/pimpmykali.git
```
```
sudo ./pimpmykali/pimpmykali.sh
```
Select the N option in the Menu

In the KALI-ROOT-LOGIN Installation page, select N
```
reboot
```
#### Set SUDO permissions for user kali
---
```
sudo apt install -y kali-grant-root && sudo dpkg-reconfigure kali-grant-root
```

select "Enable password-less privilege escalation"

```
reboot
```

#### Install and setup Terminator
---

```
sudo apt-get -y install terminator
```

```
mkdir -p $HOME/.config/terminator/plugins
```

```
wget https://git.io/v5Zww -O $HOME"/.config/terminator/plugings/terminator-themes.py"
```

In terminator Preferences:
- In Global tab
  - set "Unfocused terminal background color" to 80%
  - set "Terminal separator size:" to 4
- In Profiles tab
  - General tab
    - unset "Show titlebar"
    - unset "Use default colors"
  - In Colors tab
    - unset "Use colors from system theme"
  - In Background tab
    - set "Solid color" 
  - In Scrolling tab
    - set "Scrollbar is:" to "Disabled"
    - set Scrollback to 2000 lines
  -  In Title Bar
    - Unset "Use the system font", font should be "Sans Regular 9"
    - Change colors to:
      - Focused = White Foreground, Red Background
      - Inactive = Black Foreground, Cream Background
      - Receiving = White Foreground, Blue Background
- In the Keybindings tab
  - Change "split_horiz" to shift+atl+down
  - Change "split_vert" to shift+alt+right
  - Change "switch_to_tab_(1-10)" to alt+(1-10)
- In Plugins
  - Select CurrDirOpen
  - Select TerminatorThemes

Right click Terminator, and select "Themes" to open the Terminator Themes menu.
Select and Install these themes:
  - Batman
  - Bim
  - Dark Pastel
  - FunForrest
  - Solarized Dark High Contrast
  - Symphonic
  - Ubuntu
  - WarmNeon

Change the Default Theme to Dark Pastel based theme
```
vim ~/.config/terminator/config
```
- Replace the values in the [[default]] theme with your preferred theme under the [[Dark Pastel]] setting.
- Delete line 'foreground_color = "#ffffff"'
- Change the palette value to "#000000:#ff5555:#55ff55:#ffff55:#5555ff:#b729d9:#55ff55:#bbbbbb:#555555:#ff5555:#55ff55:#ffff55:#5555ff:#b729d9:#2777ff:#ffffff"
- In the [layouts] [[default]] [[[window0]]] section at the bottom of the config file, append the following lines:
  - order = 0
  - position = 120:73
  - maximized = False
  - fullscreen = False
  - size = 1080, 590

#### Change Terminal Prompt and zsh defaults
---

Change Terminal Prompt to better terminal prompt
  ```
  vim ~/.zshrc
  ```
  - Find "configure_prompt()" function
    - go to line starting with "PROMPT=" under the line "oneline)"
    - Change from - to:
    ```
        # From
        PROMPT=$'${debian_chroot:+($debian_chroot)}${VIRTUAL_ENV:+($(basename $VIRTUAL_ENV))}%B%F{%(#.red.blue)}%n@%m%b%F{reset}:%B%F{$(#.blue.green)}%~%b%F{reset}%(#.#.$) '
        # To
        PROMPT=$'${debian_chroot:+($debian_chroot)}${VIRTUAL_ENV:+($(basename $VIRTUAL_ENV))}%B%F{red}%n'$prompt_symbol$'%m%b%F{reset}:%B%F{blue}%~ %b%F{reset}%(#.#.$) '
    ```
  - Find the following variables, directly under "configure_prompt()" function
    - PROMPT_ALTERNATIVE=twoline
      - change from twoline to oneline
    - NEWLINE_BEFORE_PROMPT=yes
      - change to no
  
  - Find and change the following lines in the "# enable syntax-highlighting" section
    -  Change from - to:
    ```
      # From
      ZSH_HIGHLIGHT_STYLES[unknown-token]=underline
      ...
      ZSH_HIGHLIGHT_STYLES[single-hyphen-option]=fg=green
      ZSH_HIGHLIGHT_STYLES[double-hyphen-option]=fg=green

      # To
      ZSH_HIGHLIGHT_STYLES[unknown-token]=fg=red,bold
      ...
      ZSH_HIGHLIGHT_STYLES[single-hyphen-option]=fg=magenta
      ZSH_HIGHLIGHT_STYLES[double-hyphen-option]=fg=magenta
    ```

  - Find and change the following lines in the "# some more ls aliases" section
    - Change from - to:
    ```
      # From
      alias ll='ls -l'
      alias la='ls -A'
      alias l='ls -CF'

      # To
      alias ll='ls -l'
      alias la='ls -A'
      alias l='ls -CF'
      alias lait='ls -lAit'
      alias laith='ls -lAith'
    ``` 

#### Other Environment Customizations
---

In launcher options in top left, right click drop down arrow next to "Terminal Emulator". Select the + mark, add terminator, then move it to the top.

Change font:
- default font to "Sans Regular" size 11
- default monospace font to "Hack Regular" size 11

In firefox, add FoxyProxy extension in the Extensions menu

Change Background to kali-red-sticker.jpg

Set Terminator to auto open
- Open "Settings Manager"
- Open "Session and Startup"
- click on "Application Autostart"
- click "+Add" option at bottom
- Add terminator application to run on startup
  - command is "terminator"
