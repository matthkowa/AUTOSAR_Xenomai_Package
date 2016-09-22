################################################################################
#
# xenomai
#
################################################################################


XENOMAI_VERSION = v1.0

XENOMAI_SITE = git@github.com:matthkowa/AUTOSAR_Xenomai_Skin.git
XENOMAI_SITE_METHOD = git
#XENOMAI_SOURCE = xenomai-$(XENOMAI_VERSION).tar.bz2
XENOMAI_LICENSE = headers: GPLv2+ with exception, libraries: LGPLv2.1+, kernel: GPLv2+, docs: GFDLv1.2+, ipipe patch and can driver: GPLv2
# GFDL is not included but refers to gnu.org
XENOMAI_LICENSE_FILES = debian/copyright include/COPYING src/skins/native/COPYING ksrc/nucleus/COPYING

XENOMAI_INSTALL_STAGING = YES
XENOMAI_INSTALL_TARGET_OPTS = DESTDIR=$(TARGET_DIR) install-user
XENOMAI_INSTALL_STAGING_OPTS = DESTDIR=$(STAGING_DIR) install-user

ifeq ($(BR2_PACKAGE_XENOMAI_COBALT),y)
XENOMAI_CONF_OPTS += --with-core=cobalt
endif
ifeq ($(BR2_PACKAGE_XENOMAI_MERCURY),y)
XENOMAI_CONF_OPTS += --with-core=mercury
endif

XENOMAI_CONF_OPTS += --includedir=/usr/include/xenomai/ --disable-doc-install --enable-debug

XENOMAI_DIR_BUILD = $(BUILD_DIR)/xenomai-$(XENOMAI_VERSION)

XENOMAI_AUTORECONF = YES



ifeq ($(BR2_PACKAGE_XENOMAI_AUTOSAR_SKIN_TASK_1),y)
XENOMAI_MODEL_FILE = $(XENOMAI_DIR_BUILD)/test/tasks/task_1/task_1.arxml
XENOMAI_C_DIRECTORY = $(XENOMAI_DIR_BUILD)/test/tasks/task_1
endif

ifeq ($(BR2_PACKAGE_XENOMAI_AUTOSAR_SKIN_TASK_2),y)
XENOMAI_MODEL_FILE = $(XENOMAI_DIR_BUILD)/test/tasks/task_2/task_2.arxml
XENOMAI_C_DIRECTORY = $(XENOMAI_DIR_BUILD)/test/tasks/task_2
endif

ifeq ($(BR2_PACKAGE_XENOMAI_AUTOSAR_SKIN_ALARM_1),y)
XENOMAI_MODEL_FILE = $(XENOMAI_DIR_BUILD)/test/alarms/alarm_1/alarm_1.arxml
XENOMAI_C_DIRECTORY = $(XENOMAI_DIR_BUILD)/test/alarms/alarm_1
endif

ifeq ($(BR2_PACKAGE_XENOMAI_AUTOSAR_SKIN_ALARM_2),y)
XENOMAI_MODEL_FILE = $(XENOMAI_DIR_BUILD)/test/alarms/alarm_2/alarm_2.arxml
XENOMAI_C_DIRECTORY = $(XENOMAI_DIR_BUILD)/test/alarms/alarm_2
endif

ifeq ($(BR2_PACKAGE_XENOMAI_AUTOSAR_SKIN_ALARM_3),y)
XENOMAI_MODEL_FILE = $(XENOMAI_DIR_BUILD)/test/alarms/alarm_3/alarm_3.arxml
XENOMAI_C_DIRECTORY = $(XENOMAI_DIR_BUILD)/test/alarms/alarm_3
endif

ifeq ($(BR2_PACKAGE_XENOMAI_AUTOSAR_SKIN_ALARM_4),y)
XENOMAI_MODEL_FILE = $(XENOMAI_DIR_BUILD)/test/alarms/alarm_4/alarm_4.arxml
XENOMAI_C_DIRECTORY = $(XENOMAI_DIR_BUILD)/test/alarms/alarm_4
endif

ifeq ($(BR2_PACKAGE_XENOMAI_AUTOSAR_SKIN_HOOK_1),y)
XENOMAI_MODEL_FILE = $(XENOMAI_DIR_BUILD)/test/hooks/hook_1/hook_1.arxml
XENOMAI_C_DIRECTORY = $(XENOMAI_DIR_BUILD)/test/hooks/hook_1
endif

ifeq ($(BR2_PACKAGE_XENOMAI_AUTOSAR_SKIN_RESOURCE_1),y)
XENOMAI_MODEL_FILE = $(XENOMAI_DIR_BUILD)/test/resources/hook_1/resource_1.arxml
XENOMAI_C_DIRECTORY = $(XENOMAI_DIR_BUILD)/test/resources/resource_1
endif

ifeq ($(BR2_PACKAGE_XENOMAI_AUTOSAR_SKIN_CUSTOM),y)
XENOMAI_MODEL_FILE = $(BR2_PACKAGE_XENOMAI_AUTOSAR_MODEL_FILE)
XENOMAI_C_DIRECTORY = $(BR2_PACKAGE_XENOMAI_AUTOSAR_C_DIRECTORY)
endif

ifeq ($(BR2_PACKAGE_XENOMAI_AUTOSAR_SKIN),y)
define XENOMAI_AUTOSAR_MODEL_BUILD
	java -jar $(XENOMAI_DIR_BUILD)/AUTOSARGenerator/xeauge.jar -m $(XENOMAI_MODEL_FILE) -d $(XENOMAI_DIR_BUILD)
endef

XENOMAI_CONFIG = $(STAGING_DIR)/usr/bin/xeno-config
XENOMAI_CFLAGS =  $(shell DESTDIR=$(STAGING_DIR) $(XENOMAI_CONFIG) --autosar --rtdm --cflags)
XENOMAI_LDFLAGS =  $(shell DESTDIR=$(STAGING_DIR) $(XENOMAI_CONFIG) --autosar --rtdm --ldflags)
XENOMAI_CC =  $(shell DESTDIR=$(STAGING_DIR) $(XENOMAI_CONFIG) --cc)
define XENOMAI_AUTOSAR_C_BUILD
	$(XENOMAI_CC) -o $(TARGET_DIR)/usr/bin/autosar $(XENOMAI_C_DIRECTORY)/*.c  $(XENOMAI_CFLAGS) $(XENOMAI_LDFLAGS)
endef

ifeq ($(BR2_PACKAGE_XENOMAI_AUTOSAR_SKIN_AUTORUN),y)
define XENOMAI_AUTOSAR_AUTORUN
	cp $(TOPDIR)/package/xenomai/S99AutosarXenomai $(TARGET_DIR)/etc/init.d/
endef

XENOMAI_POST_INSTALL_TARGET_HOOKS += XENOMAI_AUTOSAR_AUTORUN
endif

XENOMAI_POST_INSTALL_TARGET_HOOKS += XENOMAI_AUTOSAR_C_BUILD
XENOMAI_PRE_BUILD_HOOKS += XENOMAI_AUTOSAR_MODEL_BUILD
XENOMAI_CONF_OPTS += --enable-lores-clock
endif

define XENOMAI_REMOVE_DEVFILES
	for i in xeno-config xeno-info wrap-link.sh ; do \
		rm -f $(TARGET_DIR)/usr/bin/$$i ; \
	done
endef

XENOMAI_POST_INSTALL_TARGET_HOOKS += XENOMAI_REMOVE_DEVFILES

ifeq ($(BR2_PACKAGE_XENOMAI_TESTSUITE),)
define XENOMAI_REMOVE_TESTSUITE
	rm -rf $(TARGET_DIR)/usr/share/xenomai/
	for i in klatency rtdm xeno xeno-load check-vdso \
		irqloop cond-torture-posix switchtest arith \
		sigtest clocktest cyclictest latency wakeup-time \
		xeno-test cond-torture-native mutex-torture-posix \
		mutex-torture-native ; do \
		rm -f $(TARGET_DIR)/usr/bin/$$i ; \
	done
endef

XENOMAI_POST_INSTALL_TARGET_HOOKS += XENOMAI_REMOVE_TESTSUITE
endif

ifeq ($(BR2_PACKAGE_XENOMAI_RTCAN),)
define XENOMAI_REMOVE_RTCAN_PROGS
	for i in rtcanrecv rtcansend ; do \
		rm -f $(TARGET_DIR)/usr/bin/$$i ; \
	done
	rm -f $(TARGET_DIR)/usr/sbin/rtcanconfig
endef

XENOMAI_POST_INSTALL_TARGET_HOOKS += XENOMAI_REMOVE_RTCAN_PROGS
endif

ifeq ($(BR2_PACKAGE_XENOMAI_ANALOGY),)
define XENOMAI_REMOVE_ANALOGY
	for i in cmd_bits cmd_read cmd_write insn_write \
		insn_bits insn_read ; do \
		rm -f $(TARGET_DIR)/usr/bin/$$i ; \
	done
	rm -f $(TARGET_DIR)/usr/sbin/analogy_config
	rm -f $(TARGET_DIR)/usr/lib/libanalogy.*
endef

XENOMAI_POST_INSTALL_TARGET_HOOKS += XENOMAI_REMOVE_ANALOGY
endif

XENOMAI_REMOVE_SKIN_LIST += $(if $(BR2_PACKAGE_XENOMAI_ALCHEMY_SKIN),,alchemy)
XENOMAI_REMOVE_SKIN_LIST += $(if $(BR2_PACKAGE_XENOMAI_AUTOSAR_SKIN),,autosar)
XENOMAI_REMOVE_SKIN_LIST += $(if $(BR2_PACKAGE_XENOMAI_POSIX_SKIN),,posix)
XENOMAI_REMOVE_SKIN_LIST += $(if $(BR2_PACKAGE_XENOMAI_VXWORKS_SKIN),,vxworks)
XENOMAI_REMOVE_SKIN_LIST += $(if $(BR2_PACKAGE_XENOMAI_PSOS_SKIN),,psos)
XENOMAI_REMOVE_SKIN_LIST += $(if $(BR2_PACKAGE_XENOMAI_RTDM_SKIN),,rtdm)
XENOMAI_REMOVE_SKIN_LIST += $(if $(BR2_PACKAGE_XENOMAI_SMOKEY_SKIN),,smokey)
XENOMAI_REMOVE_SKIN_LIST += $(if $(BR2_PACKAGE_XENOMAI_COBALT),,cobalt)

define XENOMAI_REMOVE_SKINS
	for i in $(XENOMAI_REMOVE_SKIN_LIST) ; do \
		rm -f $(TARGET_DIR)/usr/lib/lib$$i.* ; \
		if [ $$i == "posix" ] ; then \
			rm -f $(TARGET_DIR)/usr/lib/posix.wrappers ; \
		fi ; \
	done
endef

XENOMAI_POST_INSTALL_TARGET_HOOKS += XENOMAI_REMOVE_SKINS

define XENOMAI_DEVICES
/dev/rtheap  c  666  0  0  10  254  0  0  -
/dev/rtscope c  666  0  0  10  253  0  0  -
/dev/rtp     c  666  0  0  150 0    0  1  32
endef

ifeq ($(BR2_PACKAGE_HAS_UDEV),y)
XENOMAI_DEPENDENCIES += udev

define XENOMAI_INSTALL_UDEV_RULES
	if test -d $(TARGET_DIR)/etc/udev/rules.d ; then \
		for f in $(@D)/ksrc/nucleus/udev/*.rules ; do \
			cp $$f $(TARGET_DIR)/etc/udev/rules.d/ || exit 1 ; \
		done ; \
	fi;
endef

XENOMAI_POST_INSTALL_TARGET_HOOKS += XENOMAI_INSTALL_UDEV_RULES
endif # udev

$(eval $(autotools-package))
