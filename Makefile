meta-intel-aero-rev = 70cee044b251c1376732fe07ee359e9d93149f5f
meta-intel-aero-base-rev = 0c9f7a359c71f3c8b9f47efede194da51ccaefd7
sample-apps-rev = master
mavlink-router-rev = master

.PHONY: all clean collect aero-system download-source place-source source

all:
	find -type d -name 'debian' -not -path "./aero-kernel/*" -exec bash -c 'cd "{}/.." && debuild -uc -us' {} \;
	$(MAKE) aero-system
	
download-source:
	rm -rf src
	git clone https://github.com/intel-aero/meta-intel-aero.git src/meta-intel-aero
	git -C src/meta-intel-aero checkout $(meta-intel-aero-rev)
		
	git clone https://github.com/intel-aero/meta-intel-aero-base.git src/meta-intel-aero-base
	git -C src/meta-intel-aero-base checkout $(meta-intel-aero-base-rev)	
	
	git clone https://github.com/intel-aero/sample-apps.git src/sample-apps
	git -C src/sample-apps checkout $(sample-apps-rev)
	
	git clone https://github.com/01org/mavlink-router.git src/mavlink-router
	git -C src/mavlink-router checkout $(mavlink-router-rev)
	git -C src/mavlink-router submodule update --init --recursive

	
place-source: 
	cp src/meta-intel-aero/recipes-support/ardupilot-fw/files/* aero-ardupilot/aero-ardupilot-0.1/
	cp src/meta-intel-aero/recipes-support/jam-stapl/jam-stapl/* aero-fpga/aero-fpga-0.1/
	cp src/meta-intel-aero-base/recipes-core/initscripts-aero/files/* aero-init/aero-init-0.1/
	cp src/meta-intel-aero-base/recipes-support/fix-cameras-enumeration-order/files/* aero-init/aero-init-0.1/
	cp src/meta-intel-aero/recipes-support/px4-fw/files/* aero-px4/aero-px4-0.1
	cp src/sample-apps/spidev-app/* aero-spi-xfer/aero-spi-xfer-0.1/
	cp src/meta-intel-aero-base/recipes-support/scripts/files/* aero-utils/aero-utils-0.1
	sed -i 's/\/boot\/BIOSUPDATE.fv/\/boot\/efi\/BIOSUPDATE.fv/' aero-utils/aero-utils-0.1/aero-bios-update
	cp src/meta-intel-aero-base/recipes-support/aero-bios/files/* aero-bios/aero-bios-0.1/
	cp src/meta-intel-aero-base/recipes-support/notify-led/files/* aero-systemd/aero-systemd-0.1/
	cp src/meta-intel-aero/recipes-connectivity/networkmanager/networkmanager/firstboot-networkmanager* aero-systemd/aero-systemd-0.1/
	cp src/meta-intel-aero/recipes-core/systemd/systemd/99-usb0.network aero-systemd/aero-systemd-0.1/
	cp src/meta-intel-aero-base/recipes-kernel/linux/linux-yocto/shisp_2401a0_v21.bin firmware-atomisp/firmware-atomisp-0.1/
	sed -i 's/systemctl disable dnsmasq/systemctl disable dnsmasq || \/bin\/true/' aero-systemd/aero-systemd-0.1/firstboot-networkmanager-setup
	sed -i 's/rm \/etc\/resolv.conf/#rm \/etc\/resolv.conf/' aero-systemd/aero-systemd-0.1/firstboot-networkmanager-setup
	sed -i 's/apn \$$MODEM_APN_NAME autoconnect yes/autoconnect yes apn \$$MODEM_APN_NAME/' aero-systemd/aero-systemd-0.1/firstboot-networkmanager-setup
	rsync -a --exclude='.*' src/mavlink-router/* aero-mavlink-router/aero-mavlink-router_1.0/
	rsync src/meta-intel-aero/recipes-support/mavlink-router/files/* aero-mavlink-router/aero-mavlink-router_1.0/config/
	
	cd aero-ardupilot/aero-ardupilot-0.1/ && tar caf ../aero-ardupilot_0.1.orig.tar.xz . --exclude debian
	cd aero-fpga/aero-fpga-0.1/ && tar caf ../aero-fpga_0.1.orig.tar.xz . --exclude debian
	cd aero-init/aero-init-0.1/ && tar caf ../aero-init_0.1.orig.tar.xz . --exclude debian
	cd aero-mavlink-router/aero-mavlink-router_1.0 && tar caf ../mavlink-router_1.0.orig.tar.gz . --exclude debian
	cd aero-px4/aero-px4-0.1/ && tar caf ../aero-px4_0.1.orig.tar.xz . --exclude debian
	cd aero-spi-xfer/aero-spi-xfer-0.1/ && tar caf ../aero-spi-xfer_0.1.orig.tar.xz . --exclude debian
	cd aero-utils/aero-utils-0.1/ && tar caf ../aero-utils_0.1.orig.tar.xz . --exclude debian
	cd aero-bios/aero-bios-0.1/ && tar caf ../aero-bios_0.1.orig.tar.xz . --exclude debian
	cd aero-systemd/aero-systemd-0.1/ && tar caf ../aero-systemd_0.1.orig.tar.xz . --exclude debian
	cd firmware-atomisp/firmware-atomisp-0.1/ && tar caf ../firmware-atomisp_0.1.orig.tar.xz . --exclude debian
	
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
	$(MAKE) download-source
	$(MAKE) place-source
	
kernel-source:
	cd aero-kernel && wget http://archive.ubuntu.com/ubuntu/pool/main/l/linux/linux_4.4.0.orig.tar.gz
	cd aero-kernel && wget https://launchpadlibrarian.net/332711443/linux_4.4.0-92.115.diff.gz
	cd aero-kernel && tar -xf linux_4.4.0.orig.tar.gz
	cd aero-kernel && gunzip linux_4.4.0-92.115.diff.gz
	cd aero-kernel/linux-4.4 && patch -p1 < ../linux_4.4.0-92.115.diff
	
kernel-patch:
	cd aero-kernel/linux-4.4 && for i in `find ../patches-4.4/ -name "*.patch" | sort` ; do patch -p1 < $$i ; done
	touch aero-kernel/linux-4.4/.scmversion
	cp aero-kernel/patches-4.4/defconfig aero-kernel/linux-4.4/.config
	cd aero-kernel/linux-4.4 && yes '' | make oldconfig
	
kernel:
	cd aero-kernel/linux-4.4 && make deb-pkg -j5

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
	
aero-system:
	rm -rf aero-system/*.deb
	equivs-build aero-system/aero-system
	mv aero-system*deb aero-system/
	
