ARCHS = arm64

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = NFCShortcuts
NFCShortcuts_FILES = Tweak.xm NFCSetupPage.mm NFCDetailPage.mm
NFCShortcuts_CFLAGS = -fobjc-arc

include $(THEOS_MAKE_PATH)/tweak.mk

after-install::
	install.exec "killall -9 Shortcuts; killall -9 SpringBoard" || true
SUBPROJECTS += nfcshortcutrunner
include $(THEOS_MAKE_PATH)/aggregate.mk
