[![Build Status](https://travis-ci.org/intel-aero/packages.svg?branch=master)](https://travis-ci.org/intel-aero/packages)

# Packages

## Building

### All packages

`make`

### Only the Linux kernel 4.4 with patches

`make kernel`
After kernel build is performed successfully, debian packages will be created in `build` folder.
Also, source.changes file, dsc file and source tar file will be placed under `kernel-ppa` folder.
To Upload the generated packages to PPA,
- Sign the source.changes using :
`debsign -k <gpg_key> <linux_<version>_source.changes>`
- Upload the file after signing by :
`dput <ppa-repository> <linux_<version>_source.changes>`
File will be successfully uploaded to the `ppa-repository` and build process will be started.
After build is completed, debian packages can be downloaded and installed.

### All aero-* packages except the kernel

`make aero-packages`

### Individual packages

You can build individual packages by executing:

```
./scripts/build-pkg.sh PACKAGE-NAME
```

Where PACKAGE-NAME matches the name of the directory where the package metadata is.

### Collect

`make collect` makes all deb files available in a `packages/` directory.

### Cleanup

`make clean` cleans up the build/ directory

`make cleanall` removes all build and source files

## Utils

`./scripts/update-pkg-changelog.sh` is a helper to update the debian/changelog file
using Debian helper tools (thus, it requires such tools available in your system).

## Updating meta-intel-aero and mavlink-router revisions

New revisions sha1 must be added to the configuration file scripts/conf.

## Camera Streaming Daemon
Install librealsense alongwith Camera streaming daemon package(aero-camera-streaming-daemon) from:
			https://github.com/IntelRealSense/librealsense
For RS200, install the legacy branch of librealsense(librealsense v1)
