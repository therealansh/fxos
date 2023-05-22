# fxOS: v0.1 Rustic

[fxOS](https://fxos.framer.website/) is a hobby operating system written in Rust by [Ansh Tyagi](https://therealansh.github.io).

It targets computers with a x86-64 architecture and a BIOS, so mostly from 2005
to 2020, but it also runs well on most emulators (Bochs, QEMU, and VirtualBox).

This project started from the the second edition of Writing an OS in Rust by Philipp Oppermann and by reading the
OSDev wiki along with many open source kernels.


## Setup
```shell
make setup
```

## Usage

Build the image to `disk.img`:

    $ make image output=video keyboard=qwerty

Run fxOS in QEMU:

    $ make qemu output=video nic=rtl8139

fxOS will open a console in diskless mode after boot if no filesystem is
detected. The following command will setup the filesystem on a hard drive,
allowing you to exit the diskless mode and log in as a normal user:

    > install

**Be careful not to overwrite the hard drive of your OS when using `dd` inside
your OS, and `install` or `disk format` inside fxOS if you don't use an
emulator.**


## Tests

Run the test suite in QEMU:

    $ make test
