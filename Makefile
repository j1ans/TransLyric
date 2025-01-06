TARGET := iphone:clang:16.5:14.0
INSTALL_TARGET_PROCESSES = com.apple.Music

THEOS_PACKAGE_SCHEME=roothide
include $(THEOS)/makefiles/common.mk
TransLyrics_FRAMEWORKS = UIKit MediaPlayer Foundation
TransLyrics_PRIVATE_FRAMEWORKS = MediaPlayer
TWEAK_NAME = TransLyrics

TransLyrics_FILES = Tweak.xm
TransLyrics_CFLAGS = -fobjc-arc

include $(THEOS_MAKE_PATH)/tweak.mk
SUBPROJECTS += TransLyricPref
include $(THEOS_MAKE_PATH)/aggregate.mk
