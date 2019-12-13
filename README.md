# Diaspora* on Raspberry PI

## Introduction

- [Diaspora*](https://diasporafoundation.org/) is a self-hosted, federated social network. (pretty much a facebook clone where you own your data)
- [Raspberry PI](https://www.raspberrypi.org/) is a low cost home server solution.

The goal of this guide is to install Diaspora* on a raspberry PI to self-host you own "pod" for you and your familly.

## Requirements

- a Raspberry PI (v3 or v4)
- an microSD card (minimum recommanded size : 32G)
- ability to configure your box/modem
- a public domain name resolving to your box

Just during the installation phase :
- a TV or an hdmi screen
- an usb keyboard

## Prepare the raspberry PI

1. Download the [raspbian image](https://downloads.raspberrypi.org/raspbian_lite_latest) 
2. Install the image:
  - From [linux](https://www.raspberrypi.org/documentation/installation/installing-images/linux.md)
  - From [windows](https://www.raspberrypi.org/documentation/installation/installing-images/windows.md)
3. plug the keyboard and the screen into the rPI
4. put the microSD card into the rPI
5. put the microUSB cord and the power plug in place
6. once the PI is started connect as pi
7. password: raspberry (warning the keyboard is in US qwerty so mind your typing)
8. `sudo raspi-config`
  - Do Step *4-3* (Localisation Options - Change Keyboard Layout) and setup accordingly
  - You might want to do the others options in the step 4 too
  - Do step *1* (the pi/raspberry combo is known by the bad guys...)
  - If you connect over wifi, then do step *2-2*
  - It's a good idea to enable *5-2* (Interfacing Options - SSH) if you plan on removing the keyboard and the screen from the pi
  - Use `[tab]` to select the `Finish` button

## Install steps

### Prepare
```bash
apt-get update
apt-get install -y ansible git python3-apt
```
### Clone this repository
```bash
git clone https://github.com/sebt3/diaspora-pi.git
cd diaspora-pi
```

### Edit the configuration

Edit the file `inventory` and set `domain` and `email`.

```bash
nano inventory
```

### Start the install
```bash
ansible-playbook -i inventory install.yaml
```

### Please be patient
On the first startup diaspora will need over 10mn to be ready to use
