.PHONY: clean cleanall collect ppa aero-system kernel

PACKAGES = ardupilot bios fpga px4 init spi-xfer systemd utils mavlink-router camera-streaming-daemon optical-flow system sample-apps

AEROPKGS := $(foreach p, $(PACKAGES), build/aero-$p_*.deb) build/firmware-atomisp_*.deb

all: aero-packages kernel

aero-packages: $(AEROPKGS)

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
	cp build/*.dsc build/*.changes build/*.tar.* ppa/

