# Raspberry PI Configuration for Arch linux

This repository contains script and pre-configured dotfiles to automate installing of commonly needed packages. Tested the script on Manjaro XFCE ARM edition installed on RPi 4B.

> Please read it first and modify it according to your needs instead of blindly running it.

### Usage

```bash
$ git clone https://github.com/ManuSekhon/raspberrypi-arch-dotfiles
$ cd raspberrypi-arch-dotfiles
$ chmod a+x install.sh
$ ./install.sh
```

### Features

Some of the packages Script installs and configures are:
- Enables RPi SPI interface.
- Enables RPi I2C interface and modules.
- Enables non-root access to GPIO, SPI and I2C interface.
- Installs GPIOtest library for faulty pin testing. (use `gpiotest` on terminal to run it)
- Enables bluetooth, network, ssh, redis service if not already running.
- Replaces default shell with ZSH (Oh-my-zsh).

### Use VNC server

Script installs TigerVNC server on Raspberry Pi. You can use any client like RealVNC to remotely access desktop. Run below commands to start VNC server. I have not added these commands to startup.

```bash
# Create vnc password
$ vncpasswd
# Start VNC server
$ x0vncserver -display :0 -geometry 1280x768 -PasswordFile /home/<user>/.vnc/passwd
```

### References

- [Mohit Sakhuja's Arch dotfiles](https://github.com/iammohitsakhuja/dotfiles/tree/master/arch-manjaro) for zsh configuration and generic settings.
- [Arch ARM Wiki](https://archlinuxarm.org/wiki/Raspberry_Pi) for Raspberry PI specific settings.
- [mlowerr's raspberry-pi-setup-notes](https://github.com/mlowerr/raspberry-pi-setup-notes/blob/master/VNC%20Server%20Setup.md) for TigerVNC settings.
