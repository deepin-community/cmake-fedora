# - Manage ChangeLog
#
# Note that ChangeLog will be updated only when
#
# cmake -D cmd=update [Options] -P ManageChangeLogScript.cmake
#
# is run. This is triggered by:
# 1. Target changelog
# 2. Before source archive being built.
#
MACRO(MANAGE_CHANGELOG_SCRIPT_PRINT_USAGE)
    MESSAGE("Manage ChangeLog script: This script is not recommend for end users.

cmake -D cmd=make
      -D changelog=<path/ChangeLog>
      -D release=<path/RELEASE-NOTES.txt>
      -D prj_info=<path/prj_info.cmake>
      [-D \"<var>=<value>\"]
    -P <CmakeModulePath>/ManageChangeLogScript.cmake
    Always update ChangeLog.

cmake -D cmd=extract_current
      -D release=<path/RELEASE-NOTES.txt>
      [-D \"<var>=<value>\"]
    -P <CmakeModulePath>/ManageChangeLogScript.cmake
  Extract current Changelog items from RELEASE-NOTES.txt

cmake -D cmd=extract_prev
      -D ver=<ver>
      -D changelog=<path/ChangeLog>
      [-D \"<var>=<value>\"]
    -P <CmakeModulePath>/ManageChangeLogScript.cmake
  Extract prev Changelog items from ChangeLog.

"
	)
ENDMACRO()

MACRO(EXTRACT_CURRENT_FROM_RELEASE strVar release)
    IF("${release}" STREQUAL "")
        MANAGE_CHANGELOG_SCRIPT_PRINT_USAGE()
        M_MSG(${M_FATAL} "Requires \"-Drelease=RELEASE-NOTES.txt\"")
    ENDIF()
    IF(NOT EXISTS "${release}")
        M_MSG(${M_FATAL} "File not found:${release}")
    ENDIF()
    RELEASE_NOTES_FILE_EXTRACT_CHANGELOG_CURRENT(${strVar} ${release})
ENDMACRO()

MACRO(EXTRACT_PREV_FROM_CHANGELOG strVar ver changeLogFile)
    IF("${ver}" STREQUAL "")
        MANAGE_CHANGELOG_SCRIPT_PRINT_USAGE()
        M_MSG(${M_FATAL} "EXTRACT_PREV_FROM_CHANGELOG: Requires \"ver\"")
    ENDIF()
    IF("${changeLogFile}" STREQUAL "")
        MANAGE_CHANGELOG_SCRIPT_PRINT_USAGE()
        M_MSG(${M_FATAL} "Requires \"-Dchangelog=ChangeLog\"")
    ENDIF()
    IF(NOT EXISTS "${changeLogFile}")
        M_MSG(${M_FATAL} "File not found:${changeLogFile}")
    ENDIF()

    SET(_this "")
    SET(_prev "")
    SET(_isThis 0)
    SET(_isPrev 0)
    EXECUTE_PROCESS(COMMAND cat "${changeLogFile}"
        OUTPUT_VARIABLE _changeLogFileBuf
        OUTPUT_STRIP_TRAILING_WHITESPACE)

    STRING_SPLIT(_lines "\n" "${_changeLogFileBuf}" ALLOW_EMPTY)

    ## List should not ingore empty elements
    CMAKE_POLICY(SET CMP0007 NEW)
    LIST(LENGTH _lines _lineCount)
    MATH(EXPR _lineCount ${_lineCount}-1)
    FOREACH(_i RANGE ${_lineCount})
        LIST(GET _lines ${_i} _line)
        STRING(REGEX MATCH "^\\* [A-Za-z]+ [A-Za-z]+ [0-9]+ [0-9]+ .*<.+> - (.*)$" _match  "${_line}")
        IF("${_match}" STREQUAL "")
            # Not a version line
            IF(_isThis)
                STRING_APPEND(_this "${_line}" "\n")
            ELSEIF(_isPrev)
                STRING_APPEND(_prev "${_line}" "\n")
            ELSE(_isThis)
                M_MSG(${M_ERROR} "ChangeLog: Cannot distinguish version for line :${_line}")
            ENDIF(_isThis)
        ELSE("${_match}" STREQUAL "")
            # Is a version line
            SET(_cV "${CMAKE_MATCH_1}")
            IF("${_cV}" STREQUAL "${ver}")
                SET(_isThis 1)
                SET(_isPrev 0)
            ELSE("${_cV}" STREQUAL "${ver}")
                SET(_isThis 0)
                SET(_isPrev 1)
                STRING_APPEND(_prev "${_line}" "\n")
            ENDIF("${_cV}" STREQUAL "${ver}")
        ENDIF("${_match}" STREQUAL "")
    ENDFOREACH(_i RANGE _lineCount)
    SET(${strVar} "${_prev}")
ENDMACRO()

MACRO(CHANGELOG_MAKE prj_info release changelog)
    PRJ_INFO_CMAKE_READ("${prj_info}")

    EXTRACT_CURRENT_FROM_RELEASE(currentStr "${release}")
    IF(EXISTS "${changelog}")
        EXTRACT_PREV_FROM_CHANGELOG(prevStr "${PRJ_VER}" "${changelog}")
    ENDIF()

    EXECUTE_PROCESS(COMMAND sed -ne "/PRJ_VER/ s/PRJ_VER:STRING=//p" "${CMAKE_SOURCE_DIR}/CMakeCache.txt"
        OUTPUT_VARIABLE CachedPrjVer
        OUTPUT_STRIP_TRAILING_WHITESPACE
        )
    IF(NOT "${CachedPrjVer}" STREQUAL "${PRJ_VER}")
        EXECUTE_PROCESS(COMMAND ${CMAKE_COMMAND} "${CMAKE_SOURCE_DIR}")
    ENDIF()

    FILE(WRITE "${CMAKE_FEDORA_TMP_DIR}/ChangeLog" "* ${TODAY_CHANGELOG} ${MAINTAINER} - ${PRJ_VER}\n")
    FILE(APPEND "${CMAKE_FEDORA_TMP_DIR}/ChangeLog" "${currentStr}\n\n")
    FILE(APPEND "${CMAKE_FEDORA_TMP_DIR}/ChangeLog" "${prevStr}")
    EXECUTE_PROCESS(COMMAND diff "${CMAKE_FEDORA_TMP_DIR}/ChangeLog" "${changelog}"
        RESULT_VARIABLE different
        OUTPUT_QUIET
        ERROR_QUIET
        )
    IF(NOT different EQUAL 0)
        EXECUTE_PROCESS(COMMAND ${CMAKE_COMMAND} -E  copy "${CMAKE_FEDORA_TMP_DIR}/ChangeLog" "${changelog}")
    ENDIF()
ENDMACRO()

SET(CMAKE_ALLOW_LOOSE_LOOP_CONSTRUCTS ON)
#######################################
# Determine CMAKE_FEDORA_MODULE_DIR
#

## It is possible that current dir is in NO_PACK/FedPkg/<prj>
LIST(INSERT CMAKE_MODULE_PATH 0
    ${CMAKE_SOURCE_DIR}/Modules ${CMAKE_SOURCE_DIR}/cmake-fedora/Modules
    ${CMAKE_SOURCE_DIR}/../../../Modules
    ${CMAKE_SOURCE_DIR}/../../../cmake-fedora/Modules
    ${CMAKE_SOURCE_DIR}
    )

IF(CMAKE_SCRIPT_MODE_FILE)
    GET_FILENAME_COMPONENT(CMAKE_FEDORA_SCRIPT_DIR ${CMAKE_SCRIPT_MODE_FILE}
       PATH
       )
    LIST(INSERT CMAKE_MODULE_PATH 0 "${CMAKE_FEDORA_SCRIPT_DIR}")
ENDIF()

IF(cmake_fedora_module_dir)
    LIST(INSERT CMAKE_MODULE_PATH 0 "${cmake_fedora_module_dir}")
ENDIF()

INCLUDE(ManageMessage RESULT_VARIABLE MANAGE_MODULE_PATH)
IF(NOT MANAGE_MODULE_PATH)
    MESSAGE(FATAL_ERROR "ManageMessage.cmake cannot be found in ${CMAKE_MODULE_PATH}")
ENDIF()
GET_FILENAME_COMPONENT(CMAKE_FEDORA_MODULE_DIR
    "${MANAGE_MODULE_PATH}" PATH)

INCLUDE(ManageEnvironmentCommon)
INCLUDE(DateTimeFormat)
INCLUDE(ManageVersion)
IF(NOT DEFINED cmd)
    MANAGE_CHANGELOG_SCRIPT_PRINT_USAGE()
ELSE()
    IF("${cmd}" STREQUAL "make")
        CHANGELOG_MAKE(${prj_info} ${release} ${changelog})
    ELSEIF("${cmd}" STREQUAL "extract_current")
        EXTRACT_CURRENT_FROM_RELEASE(outVar ${release})
        M_OUT("${outVar}")
    ELSEIF("${cmd}" STREQUAL "extract_prev")
        IF("${ver}" STREQUAL "")
            MANAGE_CHANGELOG_SCRIPT_PRINT_USAGE()
            M_MSG(${M_FATAL} "Requires \"-Dver=ver\"")
        ENDIF()
        EXTRACT_PREV_FROM_CHANGELOG(outVar ${ver} ${changelog})
        M_OUT("${outVar}")
    ELSE()
        MANAGE_CHANGELOG_SCRIPT_PRINT_USAGE()
        M_MSG(${M_FATAL} "Invalid cmd ${cmd}")
    ENDIF()
ENDIF()

