.PHONY: setup image qemu
.EXPORT_ALL_VARIABLES:

setup:
	curl https://sh.rustup.rs -sSf | sh -s -- -y
	rustup install nightly
	rustup default nightly
	cargo install bootimage

# Compilation options
memory = 32
output = video# video, serial
keyboard = qwerty# qwerty, azerty, dvorak
mode = release

# Emulation options
nic = pcnet# rtl8139, pcnet
audio = coreaudio# sdl, coreaudio
kvm = false
pcap = false

export FXOS_VERSION = "v0.1"
export FXOS_MEMORY = $(memory)
export FXOS_KEYBOARD = $(keyboard)

# Build userspace binaries
user-nasm:
	basename -s .s dsk/src/bin/*.s | xargs -I {} \
    nasm dsk/src/bin/{}.s -o dsk/bin/{}.tmp
	basename -s .s dsk/src/bin/*.s | xargs -I {} \
		sh -c "printf '\x7FBIN' | cat - dsk/bin/{}.tmp > dsk/bin/{}"
	rm dsk/bin/*.tmp
user-rust:
	basename -s .rs src/bin/*.rs | xargs -I {} \
		touch dsk/bin/{}
	basename -s .rs src/bin/*.rs | xargs -I {} \
		cargo rustc --release --bin {}
	basename -s .rs src/bin/*.rs | xargs -I {} \
		cp target/x86_64-fxos/release/{} dsk/bin/{}
	#strip dsk/bin/*

bin = target/x86_64-fxos/$(mode)/bootimage-fxos.bin
img = disk.img

$(img):
	qemu-img create $(img) 32M


cargo-opts = --no-default-features --features $(output) --bin fxos
ifeq ($(mode),release)
	cargo-opts += --release
endif

# Rebuild fxOS if the features list changed
image: $(img)
	touch src/lib.rs
	env | grep FXOS
	cargo bootimage $(cargo-opts)
	dd conv=notrunc if=$(bin) of=$(img)


qemu-opts = -m $(memory) -drive file=$(img),format=raw \
			 -audiodev $(audio),id=a0 -machine pcspk-audiodev=a0 \
			 -netdev user,id=e0,hostfwd=tcp::8080-:80 -device $(nic),netdev=e0
ifeq ($(kvm),true)
	qemu-opts += -cpu host -accel kvm
else
	qemu-opts += -cpu max
endif

ifeq ($(pcap),true)
	qemu-opts += -object filter-dump,id=f1,netdev=e0,file=/tmp/qemu.pcap
endif

ifeq ($(output),serial)
	qemu-opts += -display none -chardev stdio,id=s0,signal=off -serial chardev:s0
endif

ifeq ($(mode),debug)
	qemu-opts += -s -S
endif

qemu:
	qemu-system-x86_64 $(qemu-opts)

test:
	cargo test --release --lib --no-default-features --features serial -- \
		-m $(memory) -display none -serial stdio -device isa-debug-exit,iobase=0xf4,iosize=0x04

hard-disk:
	qemu-img create disk.img 128M

clean:
	cargo clean
