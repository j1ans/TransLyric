TARGET := iphone:clang:16.5:14.0
THEOS_PACKAGE_SCHEME=roothide
include $(THEOS)/makefiles/common.mk

BUNDLE_NAME = TransLyricPref

TransLyricPref_FILES = lycRootListController.m
TransLyricPref_FRAMEWORKS = UIKit
TransLyricPref_PRIVATE_FRAMEWORKS = Preferences
TransLyricPref_INSTALL_PATH = /Library/PreferenceBundles
TransLyricPref_CFLAGS = -fobjc-arc

include $(THEOS_MAKE_PATH)/bundle.mk
