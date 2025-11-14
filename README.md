Termux Android Basic Setup

A personal Termux environment setup script for quickly configuring a clean development-ready environment on Android.
This script replaces your Termux $HOME directory and installs essential packages such as clang, python3, vim, and termux-api.


---

⚠️ Important Warning

This script deletes your existing Termux home folder and replaces it with the contents of this repository.

Only run this if you understand that all files in $HOME will be removed.


---

Features

Fresh Termux home environment

Pre-configured .config and .vim folders

Pre-configured .vimrc

Installs:

clang

python3

vim

termux-api


Fast and minimal setup



---

Requirements

Termux (latest version from F-Droid recommended)

Internet connection

Git



---

Installation

1. Clone the repository

git clone https://github.com/Dharmik-afk/Termux-android-basic-setup-.git
cd Termux-android-basic-setup-

2. Run the setup script

bash setup.sh


---

What the Script Does

1. Replaces Termux Home

Deletes your existing Termux home directory at:
/data/data/com.termux/files/home

Then moves this repository into Termux’s data directory and renames it to:
home

2. Installs Required Packages

clang
python3
vim
termux-api

3. Applies Configuration

Sets up:

.config/

.vim/

.vimrc


These provide your basic editor and environment configuration.


---

Folder Structure

.config/      — Termux/editor configuration
.vim/         — Vim configuration
.vimrc        — Main Vim configuration file
setup.sh      — Installation script
.gitignore    — Git ignore rules


---

Usage Notes

Running the script will overwrite your current home directory.

Backup before running if needed. Example:
mv ~/ ../home-backup



---

Roadmap (Planned Improvements)

Cleaner Vim configuration

Extra automation scripts

Optional developer presets



---

Contributing

This is a personal configuration repository, but pull requests are welcome.


---

License

This project intentionally has no license.
All rights reserved unless you choose to add a license later.
