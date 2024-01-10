# effective-kali-default
Default Configuration settings for fresh kali install

### Steps for default installation
---
1. Install pimpmykali
2. Insert Guest Additions CD Image
3. Set SUDO permissions for user kali
4. Install Terminator
5. Set up Terminator
6. Other Environment Customizations


#### Install pimpmykali
---

sudo apt-get update

git clone https://github.com/Dewalt-arch/pimpmykali.git

sudo ./pimpmykali/pimpmykali.sh

Select the N option in the Menu

In the KALI-ROOT-LOGIN Installation page, select N


#### Insert Guest Additions CD Image
---
In the "Device" tab in the top left, select the "Insert Guest Additions CD Image"

#### Install Terminator

sudo apt-get -y install terminator

#### Set SUDO permissions for user kali

sudo apt install -y kali-grant-root && sudo dpkg-reconfigure kali-grant-root

select "Enable password-less privilege escalation"

#### Set Up Terminator

mkdir -p $HOME/.config/terminator/plugins

wget https://git.io/v5Zww -O $HOME"/.config/terminator/plugings/terminator-themes.py"

In terminator Preferences:
- In Global tab
  - set "Unfocused terminal background color" to 80%
  - set "Re-use profiles for new terminals"
- In Profiles tab
- In the Keybindings tab
  - Change "split_horiz" to shift+atl+down
  - Change "split_vert" to shift+alt+right
  - Change "switch_to_tab_(1-10)" to alt+(1-10)
- In Plugins
  - Select CurrDirOpen
  - Select TerminatorThemes
- In Title Bar
  - Unset "Use the system font", font should be "Sans Regular 9"
  - Change colors to:
    - Focused = White Foreground, Red Background
    - Inactive = Black Foreground, Cream Background
    - Receiving = White Foreground, Blue Background

Right click Terminator, and select "Themes" to open the Terminator Themes menu.
Select and Install these themes:
  - Batman
  - CrayonPonyFish
  - Dark Pastel
  - Treehouse
  - Ubuntu
  - WarmNeon
  - Wild Cherry


#### Other Environment Customizations

In launcher options in top left, right click drop down arrow next to "Terminal Emulator". Select the + mark, add terminator, then move it to the top.

Change font:
- default font to "Sans Regular" size 11
- default monospace font to "Hack Regular" size 11

In firefox, add FoxyProxy extension in the Extensions menu

Change Background to better Background

Change Terminal Prompt to Classic Prompt
