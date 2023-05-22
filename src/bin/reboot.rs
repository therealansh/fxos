#![no_std]
#![no_main]

use fxos::api::syscall;
use fxos::entry_point;

entry_point!(main);

fn main(_args: &[&str]) {
    syscall::write(1, b"\x1b[93m"); // Yellow
    syscall::write(1, b"fxOS has reached its fate, the system is now rebooting.\n");
    syscall::write(1, b"\x1b[0m"); // Reset
    syscall::sleep(0.5);
    syscall::reboot();
    loop { syscall::sleep(1.0) }
}
