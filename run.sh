#!/bin/bash

# --- Цветовая палитра ---
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

# --- Функции вывода ---
info() { echo -e "${BLUE}[INFO]${NC} $1"; }
success() { echo -e "${GREEN}[OK]${NC} $1"; }
error() { echo -e "${RED}[ERROR]${NC} $1"; }
ask() { echo -ne "${YELLOW}[?]${NC} $1 (y/n): "; read -r res; [[ "$res" =~ ^[Yy]$ ]]; }

clear
echo -e "${MAGENTA}${BOLD}"
echo "  _  _  _  _             "
echo " | \| |(_)(_) __ _  __ _ "
echo " | .\` || || |/ _\` |/ _\` |"
echo " |_|\_||_||_|\__,_|\__,_|"
echo -e "   LIVE USB SETUP TOOL   ${NC}\n"

# 1. Настройка раскладки
if ask "Настроить русскую раскладку (Alt+Shift)?"; then
    info "Настройка клавиатуры..."
    gsettings set org.gnome.desktop.input-sources sources "[('xkb', 'us'), ('xkb', 'ru')]"
    gsettings set org.gnome.desktop.input-sources xkb-options "['grp:alt_shift_toggle']"
    success "Раскладка добавлена."
fi

# 2. Установка Micro
if ask "Установить редактор Micro?"; then
    info "Установка..."
    sudo dnf install -y micro jq &> /dev/null
    success "Micro установлен."
fi

# 3. Telegram Web
if ask "Открыть Telegram Web?"; then
    xdg-open "https://web.telegram.org" &> /dev/null &
    success "Браузер запущен."
fi

# 4. Amnezia VPN
if ask "Скачать и установить Amnezia VPN?"; then
    info "Поиск релиза..."
    LATEST_URL=$(curl -s https://api.github.com/repos/amnezia-vpn/amnezia-client/releases/latest | jq -r '.assets[] | select(.name | test("x86_64.rpm$")) | .browser_download_url' | head -n 1)
    if [ -n "$LATEST_URL" ]; then
        wget -q --show-progress "$LATEST_URL" -O amnezia.rpm
        sudo dnf install -y ./amnezia.rpm
        success "Amnezia VPN готова."
    else
        error "Релиз не найден."
    fi
fi

# 5. gptcopy
if ask "Установить gptcopy?"; then
    curl -sSL https://raw.githubusercontent.com/Fantom1901/gptcopy/main/install.sh | bash
fi

echo -e "\n${GREEN}${BOLD}Готово! Удачной сессии, Никса.${NC}"
