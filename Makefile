TARGET := iphone:clang:latest:14.0
INSTALL_TARGET_PROCESSES = MobileSMS

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = GameSeagull

GameSeagull_FILES = Tweak.x Utils.m
GameSeagull_PRIVATE_FRAMEWORKS = Preferences
GameSeagull_CFLAGS = -fobjc-arc
GameSeagull_EXTRA_FRAMEWORKS += Cephei

include $(THEOS_MAKE_PATH)/tweak.mk
SUBPROJECTS += gameseagullprefs
include $(THEOS_MAKE_PATH)/aggregate.mk
