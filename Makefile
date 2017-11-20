meta-intel-aero-rev = 70cee044b251c1376732fe07ee359e9d93149f5f
meta-intel-aero-base-rev = 0c9f7a359c71f3c8b9f47efede194da51ccaefd7
sample-apps-rev = master
mavlink-router-rev = master

.PHONY: all clean collect aero-system download-source place-source source

PACKAGES = ardupilot bios fpga px4 init spi-xfer systemd utils mavlink-router
AEROPKGS := $(foreach p, $(PACKAGES), build/aero-$p_*.deb) build/firmware-atomisp_*.deb

all: $(AEROPKGS) aero-system

build/aero-system_*.deb:
	mkdir -p build
	cd build && equivs-build ../aero-system/aero-system

build/linux-image*.deb:
	./scripts/build-kernel.sh

build/%.deb:
	./scripts/build-pkg.sh $(shell basename $@ .deb | cut -f 1 -d _)

place-source: 
	$(eval MIA_SHA= $(shell git -C src/meta-intel-aero/ rev-parse HEAD))
	$(eval MIAB_SHA= $(shell git -C src/meta-intel-aero-base/ rev-parse HEAD))
	$(eval SA_SHA= $(shell git -C src/sample-apps/ rev-parse HEAD))
	$(eval MR_SHA= $(shell git -C src/mavlink-router/ rev-parse HEAD))
	
	python scripts/insert_commit.py aero-ardupilot/aero-ardupilot-0.1/debian/control meta-intel-aero-revision $(MIA_SHA)
	python scripts/insert_commit.py aero-fpga/aero-fpga-0.1/debian/control meta-intel-aero-revision $(MIA_SHA)
	python scripts/insert_commit.py aero-init/aero-init-0.1/debian/control meta-intel-aero-base-revision $(MIAB_SHA)
	python scripts/insert_commit.py aero-px4/aero-px4-0.1/debian/control meta-intel-aero-revision $(MIA_SHA)
	python scripts/insert_commit.py aero-spi-xfer/aero-spi-xfer-0.1/debian/control meta-intel-aero-base-revision $(SA_SHA)
	python scripts/insert_commit.py aero-utils/aero-utils-0.1/debian/control meta-intel-aero-base-revision $(MIAB_SHA)
	python scripts/insert_commit.py aero-mavlink-router/aero-mavlink-router_1.0/debian/control meta-intel-aero-base-revision $(MR_SHA)
	python scripts/insert_commit.py aero-systemd/aero-systemd-0.1/debian/control meta-intel-aero-base-revision $(MIA_SHA)
	python scripts/insert_commit.py firmware-atomisp/firmware-atomisp-0.1/debian/control meta-intel-aero-base-revision $(MIAB_SHA)
	
source:
	$(MAKE) place-source
	
kernel: build/linux-image*.deb

kernel-clean:
	rm aero-kernel/linux_4.4.0.orig.tar.gz
	rm -rf aero-kernel/linux-4.4
	rm aero-kernel/linux_4.4.0-92.115.diff

clean:
	find -type d -name 'debian' -not -path "./aero-kernel/*" -exec bash -c 'cd "{}/.." && debuild clean' {} \;
	find -type f -name '*.deb' -not -path "./packages/*" -delete
	find -type f -name '*.debian.tar.xz' -delete
	find -type f -name '*.build' -delete
	find -type f -name '*.changes' -delete
	find -type f -name '*.dsc' -delete
	
collect:
	rm -rf packages
	mkdir packages
	find . -name "*.deb" -type f -exec mv {} ./packages \;
	
aero-system: build/aero-system_*.deb
