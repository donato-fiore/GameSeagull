INSTALL_TARGET_PROCESSES = SpringBoard

ARCHS = arm64

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = GameSeagull

GameSeagull_FILES = Tweak.xm
GameSeagull_CFLAGS = -fobjc-arc
GameSeagull_EXTRA_FRAMEWORKS += Cephei


include $(THEOS_MAKE_PATH)/tweak.mk
SUBPROJECTS += gameseagullprefs
include $(THEOS_MAKE_PATH)/aggregate.mk
