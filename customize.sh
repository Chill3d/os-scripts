#!/bin/bash
#-Metadata----------------------------------------------------#
#  Filename: customize.sh             (Update: 09-04-2018)      #
#-Info--------------------------------------------------------#
#  Personal post-install script for Kali Linux Rolling        #
#-Author(s)---------------------------------------------------#
#  g0tmilk ~ https://blog.g0tmi1k.com/                        #
#-Personnalized for-------------------------------------------#
#  Chill3d ~ https://github.com/Chill3d                       #
#-Licence-----------------------------------------------------#
#  MIT License ~ http://opensource.org/licenses/MIT           #
#-Notes-------------------------------------------------------#
#  Run as user to customize the OS, after install.sh          #
#                             ---                             #
#  You will need 25GB+ free HDD space before running.         #
#                             ---                             #
#  Will cut it up (so modular based), at a later date...      #
#                             ---                             #
#             ** This script is meant for _ME_. **            #
#         ** EDIT this to meet _YOUR_ requirements! **        #
#-------------------------------------------------------------#

if [ 1 -eq 0 ]; then    # This is never true, thus it acts as block comments ;)
################################################################################
### One liner - Grab the latest version and execute! ###########################
################################################################################
wget -qO customize.sh https://raw.githubusercontent.com/Chill3d/os-scripts/master/customize.sh \
  && bash customize.sh
################################################################################
fi
#-Defaults-------------------------------------------------------------#
                           
##### (Optional) Enable debug mode?
#set -x
##### (Cosmetic) Colour output
RED="\033[01;31m"      # Issues/Errors
GREEN="\033[01;32m"    # Success
YELLOW="\033[01;33m"   # Warnings/Information
BLUE="\033[01;34m"     # Heading
BOLD="\033[01;01m"     # Highlight
RESET="\033[00m"       # Normal

STAGE=0                                                         # Where are we up to
TOTAL=$( grep '(${STAGE}/${TOTAL})' $0 | wc -l );(( TOTAL-- ))  # How many things have we got todo

#-Start----------------------------------------------------------------#

echo -e " ${BLUE}[*]${RESET} ${BOLD}Kali Linux rolling post-install script - customization${RESET}"
start_time=$(date +%s)
##### Fix display output for GUI programs (when connecting via SSH)
export DISPLAY=:0.0
export TERM=xterm

##### Are we using GNOME?
if [[ $(which gnome-shell) ]]; then
  ##### Disable its auto notification package updater
  (( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Disabling GNOME's ${GREEN}notification package updater${RESET} service ~ in case it runs during this script"
  export DISPLAY=:0.0
  timeout 5 killall -w /usr/lib/apt/methods/http >/dev/null 2>&1
fi

##### Disable Touchscreen if there is one
(( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Disabling ${GREEN}Touchscreen${RESET} if there is one"
for id in `xinput --list|grep 'Touchscreen'|perl -ne 'while (m/id=(\d+)/g){print "$1\n";}'`; do
  xinput disable $id
done

##### Set audio level
(( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Setting ${GREEN}audio${RESET} levels"
systemctl --user enable pulseaudio
systemctl --user start pulseaudio
pactl set-sink-mute 0 0
pactl set-sink-volume 0 25%


if [[ $(which gnome-shell) ]]; then
  ##### Configure GNOME 3
  (( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Configuring ${GREEN}GNOME 3${RESET} ~ desktop environment"
  export DISPLAY=:0.0
  #-- Gnome Extension - Dash Dock (the toolbar with all the icons)
  gsettings set org.gnome.shell.extensions.dash-to-dock extend-height true      # Set dock to use the full height
  gsettings set org.gnome.shell.extensions.dash-to-dock dock-position 'RIGHT'   # Set dock to the right
  gsettings set org.gnome.shell.extensions.dash-to-dock dock-fixed true         # Set dock to be always visible
  gsettings set org.gnome.shell favorite-apps \
    "['org.gnome.Terminal.desktop', 'org.gnome.Nautilus.desktop', 'firefox-esr.desktop', 'kali-burpsuite.desktop', 'kali-wireshark.desktop', 'sublime_text.desktop']"
  #-- Gnome Extension - Window list
  GNOME_EXTENSIONS=$(gsettings get org.gnome.shell enabled-extensions | sed 's_^.\(.*\).$_\1_')
  echo "${GNOME_EXTENSIONS}" | grep -q "window-list@gnome-shell-extensions.gcampax.github.com" \
    || gsettings set org.gnome.shell enabled-extensions "[${GNOME_EXTENSIONS}, 'window-list@gnome-shell-extensions.gcampax.github.com']"
  #--- Top bar
  gsettings set org.gnome.desktop.interface clock-show-date true                           # Show date next to time in the top tool bar
  #--- Hide desktop icon
  dconf write /org/gnome/nautilus/desktop/computer-icon-visible false
else
  echo -e "\n\n ${YELLOW}[i]${RESET} ${YELLOW}Skipping GNOME${RESET}..." 1>&2
fi

##### Install grc
(( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Installing ${GREEN}grc${RESET} ~ colours shell output"
#--- Setup aliases
file=~/.bash_aliases; [ -e "${file}" ] && cp -n $file{,.bkup}   #/etc/bash.bash_aliases
([[ -e "${file}" && "$(tail -c 1 ${file})" != "" ]]) && echo >> "${file}"
grep -q '^## grc diff alias' "${file}" 2>/dev/null \
  || echo -e "## grc diff alias\nalias diff='$(which grc) $(which diff)'\n" >> "${file}"
grep -q '^## grc dig alias' "${file}" 2>/dev/null \
  || echo -e "## grc dig alias\nalias dig='$(which grc) $(which dig)'\n" >> "${file}"
grep -q '^## grc gcc alias' "${file}" 2>/dev/null \
  || echo -e "## grc gcc alias\nalias gcc='$(which grc) $(which gcc)'\n" >> "${file}"
grep -q '^## grc ifconfig alias' "${file}" 2>/dev/null \
  || echo -e "## grc ifconfig alias\nalias ifconfig='$(which grc) $(which ifconfig)'\n" >> "${file}"
grep -q '^## grc mount alias' "${file}" 2>/dev/null \
  || echo -e "## grc mount alias\nalias mount='$(which grc) $(which mount)'\n" >> "${file}"
grep -q '^## grc netstat alias' "${file}" 2>/dev/null \
  || echo -e "## grc netstat alias\nalias netstat='$(which grc) $(which netstat)'\n" >> "${file}"
grep -q '^## grc ping alias' "${file}" 2>/dev/null \
  || echo -e "## grc ping alias\nalias ping='$(which grc) $(which ping)'\n" >> "${file}"
grep -q '^## grc ps alias' "${file}" 2>/dev/null \
  || echo -e "## grc ps alias\nalias ps='$(which grc) $(which ps)'\n" >> "${file}"
grep -q '^## grc tail alias' "${file}" 2>/dev/null \
  || echo -e "## grc tail alias\nalias tail='$(which grc) $(which tail)'\n" >> "${file}"
grep -q '^## grc traceroute alias' "${file}" 2>/dev/null \
  || echo -e "## grc traceroute alias\nalias traceroute='$(which grc) $(which traceroute)'\n" >> "${file}"
grep -q '^## grc wdiff alias' "${file}" 2>/dev/null \
  || echo -e "## grc wdiff alias\nalias wdiff='$(which grc) $(which wdiff)'\n" >> "${file}"
#--- Apply new aliases
source "${file}" || source ~/.zshrc


##### Configure aliases - current user
(( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Configuring ${GREEN}aliases${RESET} ~ CLI shortcuts"
#--- Enable defaults - root user
for FILE in ~/.bashrc ~/.bash_aliases; do    #/etc/profile /etc/bashrc /etc/bash_aliases /etc/bash.bash_aliases
  [[ ! -f "${FILE}" ]] \
    && continue
  cp -n $FILE{,.bkup}
  sed -i 's/#alias/alias/g' "${FILE}"
done
#--- General system ones
file=~/.bash_aliases; [ -e "${file}" ] && cp -n $file{,.bkup}   #/etc/bash.bash_aliases
([[ -e "${file}" && "$(tail -c 1 ${file})" != "" ]]) && echo >> "${file}"
grep -q '^## grep aliases' "${file}" 2>/dev/null \
  || echo -e '## grep aliases\nalias grep="grep --color=always"\nalias ngrep="grep -n"\n' >> "${file}"
grep -q '^alias egrep=' "${file}" 2>/dev/null \
  || echo -e 'alias egrep="egrep --color=auto"\n' >> "${file}"
grep -q '^alias fgrep=' "${file}" 2>/dev/null \
  || echo -e 'alias fgrep="fgrep --color=auto"\n' >> "${file}"
#--- Add in ours (OS programs)
grep -q '^alias tmux' "${file}" 2>/dev/null \
  || echo -e '## tmux\nalias tmux="tmux attach || tmux new"\n' >> "${file}"    #alias tmux="tmux attach -t $HOST || tmux new -s $HOST"
grep -q '^## strings' "${file}" 2>/dev/null \
  || echo -e '## strings\nalias strings="strings -a"\n' >> "${file}"
#--- Apply new aliases
source "${file}" || source ~/.zshrc

##### Install (GNOME) Terminator
(( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Configuring (GNOME) ${GREEN}Terminator${RESET} ~ multiple terminals in a single window"
#--- Configure terminator
mkdir -p ~/.config/terminator/
file=~/.config/terminator/config; [ -e "${file}" ] && cp -n $file{,.bkup}
cat <<EOF > "${file}" \
  || echo -e ' '${RED}'[!] Issue with writing file'${RESET} 1>&2
[global_config]
  enabled_plugins = TerminalShot, LaunchpadCodeURLHandler, APTURLHandler, LaunchpadBugURLHandler
[keybindings]
[profiles]
  [[default]]
    background_darkness = 0.9
    scroll_on_output = False
    copy_on_selection = True
    background_type = transparent
    scrollback_infinite = True
    show_titlebar = False
[layouts]
  [[default]]
    [[[child1]]]
      type = Terminal
      parent = window0
    [[[window0]]]
      type = Window
      parent = ""
[plugins]
EOF
##### Install ZSH & Oh-My-ZSH - root user.   Note:  'Open terminal here', will not work with ZSH.   Make sure to have tmux already installed
(( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Installing ${GREEN}ZSH${RESET} & ${GREEN}Oh-My-ZSH${RESET} ~ unix shell"
#--- Setup oh-my-zsh
timeout 300 curl --progress -k -L -f "https://github.com/robbyrussell/oh-my-zsh/raw/master/tools/install.sh" | zsh
#--- Configure zsh
file=~/.zshrc; [ -e "${file}" ] && cp -n $file{,.bkup}   #/etc/zsh/zshrc
([[ -e "${file}" && "$(tail -c 1 ${file})" != "" ]]) && echo >> "${file}"
grep -q 'interactivecomments' "${file}" 2>/dev/null \
  || echo 'setopt interactivecomments' >> "${file}"
grep -q 'ignoreeof' "${file}" 2>/dev/null \
  || echo 'setopt ignoreeof' >> "${file}"
grep -q 'correctall' "${file}" 2>/dev/null \
  || echo 'setopt correctall' >> "${file}"
grep -q 'globdots' "${file}" 2>/dev/null \
  || echo 'setopt globdots' >> "${file}"
grep -q '.bash_aliases' "${file}" 2>/dev/null \
  || echo 'source $HOME/.bash_aliases' >> "${file}"
# Git Clone autosuggestions commands (like in fish shell)
git clone -q -b master https://github.com/zsh-users/zsh-autosuggestions.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions \
  || echo -e ' '${RED}'[!] Issue when git cloning zsh-autosuggestions'${RESET} 1>&2
#--- Configure zsh (themes) ~ https://github.com/robbyrussell/oh-my-zsh/wiki/Themes
sed -i 's/ZSH_THEME=.*/ZSH_THEME="robbyrussell"/' "${file}"   # Other themes: mh, jreese, alanpeabody, candy, terminalparty, kardan, nicoulaj, sunaku
#--- Configure oh-my-zsh plugins
sed -i 's/git)/\n  git\n  git-extras\n  tmux\n  dirhistory\n  python\n  pip\n  sublime\n  encode64\n  zsh-autosuggestions\n)/' "${file}"
#--- Set zsh as default shell (current user)
chsh -s "$(which zsh)"

##### Configure tmux - current users
(( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Configure ${GREEN}tmux${RESET} ~ multiplex virtual consoles"
file=~/.tmux.conf; [ -e "${file}" ] && cp -n $file{,.bkup}   #/etc/tmux.conf
#--- Configure tmux
cat <<EOF > "${file}" \
  || echo -e ' '${RED}'[!] Issue with writing file'${RESET} 1>&2
#-Settings---------------------------------------------------------------------
## Make it like screen (use CTRL+a)
unbind C-b
set -g prefix C-a
bind-key C-a send-prefix
## Split panes using | and -
bind | split-window -h
bind - split-window -v
unbind '"'
unbind %
## Switch panes using Alt-arrow without prefix
bind -n M-Left select-pane -L
bind -n M-Right select-pane -R
bind -n M-Up select-pane -U
bind -n M-Down select-pane -D
## Activity Monitoring
setw -g monitor-activity on
set -g visual-activity on
## Enable mouse mode
set -g mouse on
## Set defaults
set -g default-terminal screen-256color
set -g history-limit 5000
## Reload settings (CTRL+a -> r)
unbind r
bind r source-file ~/.tmux.conf
## Load custom sources
#source ~/.bashrc   #(issues if you use /bin/bash & Debian)

EOF
[ -e /bin/zsh ] \
  && echo -e '## Use ZSH as default shell\nset-option -g default-shell /bin/zsh\n' >> "${file}"
cat <<EOF >> "${file}"
## Show tmux messages for longer
set -g display-time 3000
## Status bar is redrawn every minute
set -g status-interval 60

######################
### DESIGN CHANGES ###
######################
# loud or quiet?
set-option -g visual-activity off
set-option -g visual-bell off
set-option -g visual-silence off
set-window-option -g monitor-activity off
set-option -g bell-action none
#  modes
setw -g clock-mode-colour colour5
setw -g mode-attr bold
setw -g mode-fg colour1
setw -g mode-bg colour18
# panes
set -g pane-border-bg colour0
set -g pane-border-fg colour4
set -g pane-active-border-bg colour0
set -g pane-active-border-fg colour9
# statusbar
set -g status-position bottom
set -g status-justify left
#Background bar
set -g status-bg colour244
set -g status-fg colour219
set -g status-attr dim
set -g status-left ''
#Date at right
set -g status-right '#[fg=colour233,bg=colour247,bold] %d/%m #[fg=colour233,bg=colour250,bold] %H:%M:%S '
set -g status-right-length 50
set -g status-left-length 20
# Current windows color on the statusbar
setw -g window-status-current-fg colour51 #Window number
setw -g window-status-current-bg colour250
setw -g window-status-current-attr bold
setw -g window-status-current-format ' #I#[fg=colour250]:#[fg=colour51]#W#[fg=colour250]#F '
# Windows unused color on the statusbar
setw -g window-status-fg colour9
setw -g window-status-bg colour246
setw -g window-status-attr none
setw -g window-status-format ' #I#[fg=colour246]:#[fg=colour9]#W#[fg=colour246]#F '
# messages
set -g message-attr bold
set -g message-fg colour15
set -g message-bg colour16
EOF
#--- Setup startup
file=~/.zshrc; [ -e "${file}" ] && cp -n $file{,.bkup}   #/etc/tmux.conf
echo -e '## tmux\nif [[ ! $TERM =~ screen ]]; then\n   exec tmux\nfi\n' >> "${file}"
#--- Setup alias
file=~/.bash_aliases; [ -e "${file}" ] && cp -n $file{,.bkup}   #/etc/bash.bash_aliases
([[ -e "${file}" && "$(tail -c 1 ${file})" != "" ]]) && echo >> "${file}"
grep -q '^alias tmux' "${file}" 2>/dev/null \
  || echo -e '## tmux\nalias tmux="tmux attach || tmux new"\n' >> "${file}"    #alias tmux="tmux attach -t $HOST || tmux new -s $HOST"
#--- Apply new alias
source "${file}" || source ~/.zshrc

##### Configure Dirsearch alias
(( STAGE++ )); echo -e "\n\n ${GREEN}[+]${RESET} (${STAGE}/${TOTAL}) Configure ${GREEN}Dirsearch${RESET} ~ Web Path Scanner"
#--- Setup alias
file=~/.bash_aliases; [ -e "${file}" ] && cp -n $file{,.bkup}   #/etc/bash.bash_aliases
([[ -e "${file}" && "$(tail -c 1 ${file})" != "" ]]) && echo >> "${file}"
grep -q '^## dirsearch' "${file}" 2>/dev/null \
  || echo -e '## dirsearch\nalias dirsearch="/opt/dirsearch-git/dirsearch.py"\n' >> "${file}"
#--- Apply new alias
source "${file}" || source ~/.zshrc

##### Time taken
finish_time=$(date +%s)
echo -e "\n\n ${YELLOW}[i]${RESET} Time (roughly) taken: ${YELLOW}$(( $(( finish_time - start_time )) / 60 )) minutes${RESET}"
echo -e " ${YELLOW}[i]${RESET} Stages skipped: $(( TOTAL-STAGE ))"

##### Done!
echo -e "\n ${YELLOW}[i]${RESET} Don't forget to:"
echo -e " ${YELLOW}[i]${RESET} + Check the above output (Did everything install? Any errors? (${RED}HINT: What's in RED${RESET}?)"
echo -e " ${YELLOW}[i]${RESET} + Setup git:   ${YELLOW}git config --global user.name <name>;git config --global user.email <email>${RESET}"
echo -e " ${YELLOW}[i]${RESET} + ${BOLD}Change default passwords${RESET}: PostgreSQL/MSF, MySQL, Neo4j etc."
echo -e " ${YELLOW}[i]${RESET} + ${BOLD}Log into Firefox to load stuff${RESET}: bookmarks etc."
echo -e " ${YELLOW}[i]${RESET} + ${YELLOW}Reboot${RESET}"
echo -e '\n'${BLUE}'[*]'${RESET}' '${BOLD}'Done!'${RESET}'\n\a'
exit 0
