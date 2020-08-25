THEOS_DEVICE_IP = haotestlabs.com
THEOS_DEVICE_PORT = 28262

ARCHS = arm64

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = NFCShortcutRunner
NFCShortcutRunner_FILES = Tweak.xm
NFCShortcutRunner_CFLAGS = -fobjc-arc

include $(THEOS_MAKE_PATH)/tweak.mk

after-install::
	install.exec "killall -9 SpringBoard"
