cmake_minimum_required(VERSION 2.6.2)

# Included scripts do automatic cmake_policy PUSH and POP.
# OLD: CMake policy in included script will affect the invoker.
# CMAKE_POLICY(SET CMP0011 OLD)

LIST(INSERT CMAKE_MODULE_PATH 0 ${CMAKE_SOURCE_DIR}/Modules)
INCLUDE(ManageEnvironmentCommon RESULT_VARIABLE MANAGE_ENVIRONMENT_PATH)
GET_FILENAME_COMPONENT(CMAKE_FEDORA_MODULE_DIR
    "${MANAGE_ENVIRONMENT_PATH}" PATH CACHE
    )

# Whether to build on fedora
SET(CMAKE_FEDORA_ENABLE_FEDORA_BUILD "1" CACHE STRING "Enable fedora build" FORCE)

####################################################################
# Project specific information
#
PROJECT(cmake-fedora NONE)
SET(PRJ_SUMMARY "CMake helper modules for fedora developers")

SET(PRJ_DESCRIPTION
"cmake-fedora consist a set of cmake modules that provides
helper macros and targets for fedora developers."
    )
SET(AUTHORS "Ding-Yi Chen")
SET(MAINTAINER "Ding-Yi Chen <dchen at redhat.com>")
SET(VENDOR "Red Hat, APAC, Inc.")
SET(LICENSE BSD)
SET(PRJ_GROUP "System Environment/Libraries")
SET(BUILD_ARCH "noarch")
SET(RPM_SPEC_URL "https://pagure.io/%{name}/")
SET(RPM_SPEC_SOURCES "https://releases.pagure.org/%{name}/%{name}-%{version}-Source.tar.gz")

####################################################################
# Includes
#
INCLUDE(ManageEnvironment)
INCLUDE(ManageArchive)
INCLUDE(ManageVersion)
RELEASE_NOTES_READ_FILE()
INCLUDE(ManageDependency)
INCLUDE(ManageFile)
INCLUDE(ManageSourceVersionControl)
INCLUDE(ManageTarget)
INCLUDE(ManageUninstall)
ENABLE_TESTING()

####################################################################
# Dependencies
#

## Requires
MANAGE_DEPENDENCY(REQUIRES CMAKE VER "2.6.2")
MANAGE_DEPENDENCY(REQUIRES GIT)

MANAGE_DEPENDENCY(REQUIRES BODHI-CLIENT)
MANAGE_DEPENDENCY(REQUIRES KOJI)
MANAGE_DEPENDENCY(REQUIRES RPM-BUILD)
MANAGE_DEPENDENCY(REQUIRES FEDPKG)
MANAGE_DEPENDENCY(REQUIRES FEDORA-PACKAGER)
MANAGE_DEPENDENCY(REQUIRES CURL)
MANAGE_DEPENDENCY(REQUIRES PACKAGEDB-CLI)

## Build requires
MANAGE_DEPENDENCY(BUILD_REQUIRES CMAKE VER "2.6.2" REQUIRED)
MANAGE_DEPENDENCY(BUILD_REQUIRES KOJI REQUIRED)


####################################################################
# Building
#


####################################################################
# Installing
#

INSTALL(FILES AUTHORS README.md ChangeLog COPYING
    DESTINATION ${PRJ_DOC_DIR}
    )
INSTALL(FILES cmake-fedora.conf
    DESTINATION ${SYSCONF_DIR}
    )

ADD_SUBDIRECTORY(Modules)
ADD_SUBDIRECTORY(scripts)
ADD_SUBDIRECTORY(Templates)

MANAGE_SOURCE_VERSION_CONTROL_GIT()

####################################################################
# Packing
#

ADD_CUSTOM_TARGET(test_all
    COMMAND ctest -C Debug --output-on-failure
    COMMENT "ctest: Run tests"
    )
ADD_DEPENDENCIES(pack_src_pre test_all)

## Pack Source
SET(SOURCE_ARCHIVE_DIR ${CMAKE_BINARY_DIR}/SOURCES CACHE PATH "Source Archive Dir")
PACK_SOURCE_ARCHIVE("${SOURCE_ARCHIVE_DIR}"
    GITIGNORE ${CMAKE_SOURCE_DIR}/.gitignore
    )

IF(CMAKE_FEDORA_ENABLE_FEDORA_BUILD)
    SET(RPM_BUILD_SOURCES ${SOURCE_ARCHIVE_DIR})
    INCLUDE(ManageRPM)
    RPM_SPEC_STRING_ADD_DIRECTIVE(RPM_SPEC_SCRIPT_OUTPUT check "" "ctest --output-on-failure")
    PACK_RPM(SPEC_IN "Templates/fedora/project.spec.in")
    RPM_MOCK_BUILD()
ENDIF(CMAKE_FEDORA_ENABLE_FEDORA_BUILD)

####################################################################
# Hosting
#

####################################################################
# Custom
#

# Module-only tarballs
INCLUDE(ManageTarget)
SET(MODULE_ONLY_ARCHIVE ${PROJECT_NAME}-${PRJ_VER}-modules-only.tar.gz)
SET(MODULE_ONLY_LATEST_ARCHIVE ${PROJECT_NAME}-modules-only-latest.tar.gz)
ADD_CUSTOM_TARGET_COMMAND(module-only
    OUTPUT ${MODULE_ONLY_ARCHIVE} ${MODULE_ONLY_LATEST_ARCHIVE}
    COMMAND tar --exclude=.* -czvf  ${MODULE_ONLY_ARCHIVE} Modules/*.cmake Modules/*.cmake.in
    COMMAND ln -sf ${MODULE_ONLY_ARCHIVE} ${MODULE_ONLY_LATEST_ARCHIVE}
    )

ADD_DEPENDENCIES(tag_pre module-only)

####################################################################
# Release
#

INCLUDE(ManageRelease)
IF(CMAKE_FEDORA_ENABLE_FEDORA_BUILD)
    INCLUDE(ManageReleaseFedora)
    RELEASE_FEDORA(fedora epel7 el6)
    # "Off" Warning is displayed if mock is not installed.
    MANAGE_RELEASE(tag_push release_fedora)
ELSE(CMAKE_FEDORA_ENABLE_FEDORA_BUILD)
    MANAGE_RELEASE(tag_push)
ENDIF(CMAKE_FEDORA_ENABLE_FEDORA_BUILD)

####################################################################
# Test Suites.
#
ADD_TEST("ManageString" ctest -S test/testManageString.cmake)
ADD_TEST("ManageVariable" ctest -S test/testManageVariable.cmake)
ADD_TEST("ManageFile" ctest -S test/testManageFile.cmake)
ADD_TEST("ManageTranslation" ctest -S test/testManageTranslation.cmake)
ADD_TEST("CmakeFedoraScript" ctest -S test/testCmakeFedoraScript.cmake)
ADD_TEST("CmakeFedoraFedpkg" ctest -S test/testCmakeFedoraFedpkg.cmake)

IF(CMAKE_VERSION VERSION_GREATER 2.8.0)
    ##  These tests requires internet, which should not be run in koji
    ADD_TEST(NAME "CmakeFedoraKoji"
        CONFIGURATIONS "Debug"
        COMMAND ctest -S test/testCmakeFedoraKoji.cmake
        )
    ADD_TEST(NAME "CmakeFedoraFedpkgDeep"
        CONFIGURATIONS "Debug"
        COMMAND ctest -S test/testCmakeFedoraFedpkgDeep.cmake
        )
    ADD_TEST(NAME "ManageZanata"
    	CONFIGURATIONS "Debug"
	    COMMAND ctest -S test/testManageZanata.cmake
        )
    ADD_TEST(NAME "cmake-fedora-newprj"
	    CONFIGURATIONS "Debug"
	    COMMAND ctest -S test/testCmakeFedoraNewprj.cmake
	    )
ENDIF(CMAKE_VERSION VERSION_GREATER 2.8.0)

