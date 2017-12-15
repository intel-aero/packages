meta-intel-aero-rev = 70cee044b251c1376732fe07ee359e9d93149f5f
meta-intel-aero-base-rev = 051ab4f3ebc9798a2d2d234487e9c92d8b3894c2
sample-apps-rev = master
mavlink-router-rev = master
camera-streaming-daemon-rev = master

.PHONY: clean cleanall collect ppa aero-system kernel

PACKAGES = ardupilot bios fpga px4 init spi-xfer systemd utils mavlink-router camera-streaming-daemon optical-flow

AEROPKGS := $(foreach p, $(PACKAGES), build/aero-$p_*.deb) build/firmware-atomisp_*.deb

all: aero-packages kernel

aero-packages: $(AEROPKGS) aero-system aero-sample-apps

build/aero-system_*.deb:
	mkdir -p build
	cd build && equivs-build ../aero-system/aero-system

build/aero-sample-apps_*.deb:
	mkdir -p build
	cd build && equivs-build ../aero-sample-apps/aero-sample-apps

build/linux-image*.deb:
	./scripts/build-kernel.sh

build/%.deb:
	./scripts/build-pkg.sh $(shell basename $@ .deb | cut -f 1 -d _)

kernel: build/linux-image*.deb

clean:
	rm -rf build

cleanall: clean
	rm -rf src

collect:
	rm -rf packages
	mkdir packages
	cp build/*.deb packages/

ppa:
	rm -rf ppa
	mkdir ppa
	cp build/*.dsc build/*.changes build/*.debian.tar.* ppa/

aero-system: build/aero-system_*.deb

aero-sample-apps: build/aero-sample-apps_*.deb
