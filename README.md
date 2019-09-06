# My dotfiles

### Requirements
 Im a [Arch Linux ](https://www.archlinux.org/download/ "Arch Linux ")user. So if you want to using my dotfiles maybe some depedencies will be has different name. You can search for it on the official website.
 
 [![my vim](https://github.com/nandhasuhendra/dotfiles "my vim")](https://raw.githubusercontent.com/nandhasuhendra/dotfiles/master/screenshot.png "my vim")
 
The dependencies that I use on the operating system:
- rbenv: [rbenv](https://github.com/rbenv/rbenv "rbenv")
- nvm: [nvm](https://github.com/nvm-sh/nvm "nvm")
- Font: [FiraCode](https://github.com/tonsky/FiraCode "FiraCode")
- Oh-My-Zsh: [oh-my-zsh](https://github.com/robbyrussell/oh-my-zsh "oh-my-zsh")
- TMP: [tmp](https://github.com/tmux-plugins/tpm "tmp")

1. Install Ruby with rbenv
```bash
:$ git clone https://github.com/rbenv/rbenv.git ~/.rbenv
:$ echo 'export PATH="$HOME/.rbenv/bin:$PATH"' >> $SHELL
:$ ~/.rbenv/bin/rbenv init
```
If you want to install Install Ruby 2.2.x you will get an error. So you need to install `gcc6`, `gcc6-libs` and `openssl1.0`. and run this command for install ruby version, download file [here](http://instarch.codekoala.com/x86_64/ "download"). I hope this is still alive.
```bash
:$ CC=gcc-6 PKG_CONFIG_PATH=/usr/lib/openssl-1.0/pkgconfig RUBY_EXTRA_CONFIGURE_OPTIONS="--with-openssl-dir=/usr/lib/openssl-1.0" rbenv install 2.2.x
```
For newer Ruby version 2.5.x +
```bash
:$ rbenv install <ruby-version>
```
2. Install nvm
```bash
:$ curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.34.0/install.sh | bash
:$ echo "export NVM_DIR="$([ -z "${XDG_CONFIG_HOME-}" ] && printf %s "${HOME}/.nvm" || printf %s "${XDG_CONFIG_HOME}/nvm")" >> $SHELL
:$ echo "[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"" >> $SHELL
```
3. Install Ctags
```bash
:$ sudo pacman -S ctags
```
4. Install the_silver_searcher
```bash
:$ sudo pacman -S the_silver_searcher
```
5. Install xclip xsel
```bash
:$ sudo pacman -S xclip xsel
```
6. Install zsh-autosuggestions & zsh-syntax-highlighting[]()
```bash
:$ sudo pacman -S zsh-autosuggestions zsh-syntax-highlighting
```
