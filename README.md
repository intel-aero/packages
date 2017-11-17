[![Build Status](https://travis-ci.org/intel-aero/packages.svg?branch=master)](https://travis-ci.org/intel-aero/packages)

# Packages

## Building

### Automatic process to build all packages (recommended)

Use `scripts/build.sh` to build all packages and place the deb files into a `packages/` directory.

### Manual process
#### Source setup
If you just got the fresh git directory, you need to set it up for building first.
To download the upstream sources and place them where they're needed, run `make source`.
Once you do that everything will be in place for building.
#### Building
After the sources are in place, you can build all packages by just calling `make`.

To collect all the .deb files into a packages/ folder you can run `make collect`.

If you want to build a package invidually you can just go into its folder and run the required build command.

#### The Kernel
To download the clean kernel source, run `make kernel-source`.

To patch the kernel with the patches in aero-kernel/patches, run `make kernel-patch`.
(Any patch errors will result in .rej files in next to the target)

To build the kernel, run `make kernel`.

Clean kernel: `make kernel-clean`

#### Camera Streaming Daemon
Install librealsense alongwith Camera streaming daemon package(aero-camera-streaming-daemon) from:
			https://github.com/IntelRealSense/librealsense
For RS200, install the legacy branch of librealsense(librealsense v1)
