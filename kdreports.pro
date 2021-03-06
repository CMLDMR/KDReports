##
## This file is part of the KD Reports library.
##
## SPDX-FileCopyrightText: 2014-2021 Klarälvdalens Datakonsult AB, a KDAB Group company <info@kdab.com>
##
## SPDX-License-Identifier: LGPL-2.1-only OR LGPL-3.0-only OR GPL-2.0-only OR GPL-3.0-only OR LicenseRef-KDAB-KDReports OR LicenseRef-KDAB-KDReports-US
##
## Licensees holding valid commercial KD Reports licenses may use this file in
## accordance with the KD Reports Commercial License Agreement provided with
## the Software.
##
## Contact info@kdab.com if any conditions of this licensing are not clear to you.
##

system('echo ==================================================================================')
system('echo The QMake Buildsystem is deprecated and will be removed in the next major release.')
system('echo Please consider migrating to the CMake Buildsystem at your earliest opportunity.')
system('echo Instructions can be found in INSTALL-cmake.txt')
system('echo ==================================================================================')
system('echo')

TEMPLATE = subdirs
system($$system_path(./gen-forward-headers.py))|error("Can't generate forward headers, please ensure python is available from this shell.")
SUBDIRS  = include src
!no_examples: SUBDIRS += examples
unittests: SUBDIRS += unittests
CONFIG   += ordered
VERSION  = 1.9.50
MAJOR_VERSION = 1

unix:DEFAULT_INSTALL_PREFIX = /usr/local/KDAB/KDReports-$$VERSION
win32:DEFAULT_INSTALL_PREFIX = "C:\KDAB\KDReports"-$$VERSION

# for backw. compat. we still allow manual invocation of qmake using PREFIX:
isEmpty( KDREPORTS_INSTALL_PREFIX ): KDREPORTS_INSTALL_PREFIX=$$PREFIX

# if still empty we use the default:
isEmpty( KDREPORTS_INSTALL_PREFIX ): KDREPORTS_INSTALL_PREFIX=$$DEFAULT_INSTALL_PREFIX

# if the default was either set by configure or set by the line above:
equals( KDREPORTS_INSTALL_PREFIX, $$DEFAULT_INSTALL_PREFIX ){
    INSTALL_PREFIX=$$DEFAULT_INSTALL_PREFIX
    unix:message( "No install prefix given, using default of" $$DEFAULT_INSTALL_PREFIX (use configure.sh -prefix DIR to specify))
    !unix:message( "No install prefix given, using default of" $$DEFAULT_INSTALL_PREFIX (use configure -prefix DIR to specify))
} else {
    INSTALL_PREFIX=$$KDREPORTS_INSTALL_PREFIX
}

DEBUG_SUFFIX=""
VERSION_SUFFIX=""
CONFIG(debug, debug|release) {
  !unix: DEBUG_SUFFIX = d
}
!unix:!mac:!static:VERSION_SUFFIX=$$MAJOR_VERSION

KDREPORTSLIB = kdreports$$VERSION_SUFFIX$$DEBUG_SUFFIX
KDREPORTSTESTTOOLSLIB = kdreporttesttools$$VERSION_SUFFIX$$DEBUG_SUFFIX
message(Install prefix is $$INSTALL_PREFIX)
message(This is KD Reports version $$VERSION)

# These files are in the build directory (Because "somecommand >> somefile" puts them there)
CONFQMAKE_CACHE = "$${OUT_PWD}/.confqmake.cache"
QMAKE_CACHE = "$${OUT_PWD}/.qmake.cache"

# Create a .qmake.cache file
unix:MESSAGE = '\\'$$LITERAL_HASH\\' KDAB qmake cache file: autogenerated during qmake run'
!unix:MESSAGE = $$LITERAL_HASH' KDAB qmake cache file: autogenerated during qmake run'

system('echo $${MESSAGE} > $${QMAKE_CACHE}')

TMP_SOURCE_DIR = $${IN_PWD}
TMP_BUILD_DIR = $${OUT_PWD}
system('echo TOP_SOURCE_DIR=$${TMP_SOURCE_DIR} >> $${QMAKE_CACHE}')
system('echo TOP_BUILD_DIR=$${TMP_BUILD_DIR} >> $${QMAKE_CACHE}')
windows:INSTALL_PREFIX=$$replace(INSTALL_PREFIX, \\\\, /)
system('echo INSTALL_PREFIX=$$INSTALL_PREFIX >> $${QMAKE_CACHE}')
system('echo VERSION=$$VERSION >> $${QMAKE_CACHE}')
system('echo KDREPORTSLIB=$$KDREPORTSLIB >> $${QMAKE_CACHE}')
system('echo KDREPORTSTESTTOOLSLIB=$$KDREPORTSTESTTOOLSLIB >> $${QMAKE_CACHE}')

# forward make test calls to unittests:
test.target=test
unix:!macx:test.commands=export LD_LIBRARY_PATH=\"$${OUT_PWD}/lib\":$$(LD_LIBRARY_PATH); (cd unittests && $(MAKE) test)
macx:test.commands=export DYLD_LIBRARY_PATH=\"$${OUT_PWD}/lib\":$$(DYLD_LIBRARY_PATH); (cd unittests && $(MAKE) test)
win32:test.commands=(cd unittests && $(MAKE) test)
test.depends = $(TARGET)
QMAKE_EXTRA_TARGETS += test

INSTALL_DOC_DIR = $$INSTALL_PREFIX/share/doc/KDReports

# install licenses:
licenses.files = LICENSES/*
licenses.path = $$INSTALL_DOC_DIR/LICENSES
INSTALLS += licenses

# install readme:
readme.files = README.txt README-commercial.txt
readme.path = $$INSTALL_DOC_DIR
INSTALLS += readme

# install qmake project includes
prifiles.files = kdreports.pri
prifiles.path = $$INSTALL_DOC_DIR
INSTALLS += prifiles

OTHER_FILES += configure.sh configure.bat kdreports.pri doc/CHANGES*
