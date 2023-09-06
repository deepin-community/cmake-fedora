# - Manage Translation
# This module supports software translation by:
#   Creates gettext related targets.
#   Communicate to Zanata servers.
#
# By calling MANAGE_GETTEXT(), following variables are available in cache:
#   - MANAGE_TRANSLATION_LOCALES: Locales that would be processed.
#
# Included Modules:
#   - ManageArchive
#   - ManageDependency
#   - ManageFile
#   - ManageMessage
#   - ManageString
#   - ManageVariable
#   - ManageZanataSuggest
#
# Defines following targets:
#   + translations: Virtual target that make the translation files.
#     Once MANAGE_GETTEXT is used, this target invokes targets that
#     build translation.
#
# Defines following variables:
#   + XGETTEXT_OPTIONS_C: Default xgettext options for C programs.
# Defines or read from following variables:
#   + MANAGE_TRANSLATION_MSGFMT_OPTIONS: msgfmt options
#     Default: --check --check-compatibility --strict
#   + MANAGE_TRANSLATION_MSGMERGE_OPTIONS: msgmerge options
#     Default: --update --indent --backup=none
#   + MANAGE_TRANSLATION_XGETEXT_OPTIONS: xgettext options
#     Default: ${XGETTEXT_OPTIONS_C}
#
# Defines following functions:
#   MANAGE_POT_FILE(<potFile> 
#       [SRCS <src> ...]
#       [PO_DIR <dir>]
#       [MO_DIR <dir>|MO_LOCALE_DIR <dir>| NO_MO]
#       [NO_MO]
#	[LOCALES <locale> ... | SYSTEM_LOCALES]
#	[XGETTEXT_OPTIONS <opt> ...]
#       [MSGMERGE_OPTIONS <msgmergeOpt>]
#       [MSGFMT_OPTIONS <msgfmtOpt>]
#       [CLEAN]
#       [COMMAND <cmd> ...]
#       [DEPENDS <file> ...]
#     )
#     - Add a new pot file and source files that create the pot file.
#       It is mandatory if for multiple pot files.
#       By default, cmake-fedora will set the directory property
#       PROPERTIES CLEAN_NO_CUSTOM as "1" to prevent po files get cleaned
#       by "make clean". For this behavior to be effective, invoke this function
#       in the directory that contains generated PO file.
#       * Parameters:
#         + <potFile>: .pot file with path.
#         + SRCS <src> ... : Source files for xgettext to work on.
#         + DOMAIN_NAME <domainName>: gettext domain name.
#           Default: .pot filename without extension.
#         + PO_DIR <dir>: Directory of .po files.
#             This option is mandatory if .pot and associated .po files
#             are not in the same directory.
#           Default: Same directory of <potFile>.
#         + MO_DIR dir: Directory to create .gmo files. The .gmo files 
#           are created as: <dir>/<locale>.gmo
#           This option collide with NO_MO and MO_LOCALE_DIR.
#           Default: Same with PO_DIR
#         + MO_LOCALE_DIR dir: Directory to create .mo files. The .mo files 
#           are created as: <dir>/locale/<locale>/LC_MESSAGES/<domainName>.mo
#           This option collide with NO_MO and MO_DIR.
#         + NO_MO: Skip the mo generation, usually for document trnslation
#           that do not require MO.
#           This option collide with MO_DIR and MO_LOCALE_DIR.
#         + LOCALES locale ... : (Optional) Locale list to be generated.
#         + SYSTEM_LOCALES: (Optional) System locales from /usr/share/locale.
#         + XGETTEXT_OPTIONS opt ... : xgettext options.
#         + MSGMERGE_OPTIONS msgmergeOpt: (Optional) msgmerge options.
#           Default: ${MANAGE_TRANSLATION_MSGMERGE_OPTIONS}, which is
#         + MSGFMT_OPTIONS msgfmtOpt: (Optional) msgfmt options.
#           Default: ${MANAGE_TRANSLATION_MSGFMT_OPTIONS}
#         + CLEAN: Clean the POT, PO, MO files when doing make clean
#             By default, cmake-fedora will set the directory property
#             PROPERTIES CLEAN_NO_CUSTOM as "1" to prevent po files get cleaned.
#             Specify "CLEAN" to override this behavior.
#         + COMMAND cmd ... : Non-xgettext command that create pot file.
#         + DEPENDS file ... : Files that pot file depends on.
#             SRCS files are already depended on, so no need to list here.
#       * Variables to cache:
#         + MANAGE_TRANSLATION_GETTEXT_POT_FILES: List of pot files.
#         + MANAGE_TRANSLATION_GETTEXT_PO_FILES: List of all po files.
#         + MANAGE_TRANSLATION_GETTEXT_MO_FILES: List of all mo filess.
#         + MANAGE_TRANSLATION_LOCALES: List of locales.
#
#   MANAGE_GETTEXT([ALL] 
#       [POT_FILE <potFile>]
#       [SRCS <src> ...]
#       [PO_DIR <dir>]
#       [MO_DIR <dir>]
#       [NO_MO]
#	[LOCALES <locale> ... | SYSTEM_LOCALES]
#	[XGETTEXT_OPTIONS <opt> ...]
#       [MSGMERGE_OPTIONS <msgmergeOpt>]
#       [MSGFMT_OPTIONS <msgfmtOpt>]
#       [CLEAN]
#       [DEPENDS <file> ...]
#     )
#     - Manage Gettext support.
#       If no POT files were added, it invokes MANAGE_POT_FILE and manage .pot, .po and .gmo files.
#       This command creates targets for making the translation files.
#       So naturally, this command should be invoke after the last MANAGE_POT_FILE command.
#       The parameters are similar to the ones at MANAGE_POT_FILE, except:
#       * Parameters:
#         + ALL: (Optional) make target "all" depends on gettext targets.
#         + POT_FILE potFile: (Optional) pot files with path.
#           Default: ${CMAKE_CURRENT_BINARY_DIR}/${PROJECT_NAME}.pot
#         Refer MANAGE_POT_FILE for rest of the parameters.
#       * Targets:
#         + pot_files: Generate pot files.
#         + update_po: Update po files according to pot files.
#         + gmo_files: Converts po files to mo files.
#         + translation: Complete all translation tasks.
#       * Variables to cache:
#         + MANAGE_TRANSLATION_GETTEXT_POT_FILES: List of pot files.
#         + MANAGE_TRANSLATION_GETTEXT_PO_FILES: List of all po files.
#         + MANAGE_TRANSLATION_GETTEXT_MO_FILES: Lis of all mo filess.
#         + MANAGE_TRANSLATION_LOCALES: List of locales. 
#       * Variables to cache:
#         + MSGINIT_EXECUTABLE: the full path to the msginit tool.
#         + MSGMERGE_EXECUTABLE: the full path to the msgmerge tool.
#         + MSGFMT_EXECUTABLE: the full path to the msgfmt tool.
#         + XGETTEXT_EXECUTABLE: the full path to the xgettext.
#         + MANAGE_LOCALES: Locales to be processed.
#

IF(DEFINED _MANAGE_TRANSLATION_CMAKE_)
    RETURN()
ENDIF(DEFINED _MANAGE_TRANSLATION_CMAKE_)
SET(_MANAGE_TRANSLATION_CMAKE_ "DEFINED")
INCLUDE(ManageMessage)
INCLUDE(ManageFile)
INCLUDE(ManageString)
INCLUDE(ManageVariable)
INCLUDE(ManageZanataSuggest)

#######################################
# GETTEXT support
#

SET(XGETTEXT_OPTIONS_COMMON --from-code=UTF-8 --indent
    --sort-by-file
    )

SET(XGETTEXT_OPTIONS_C ${XGETTEXT_OPTIONS_COMMON} 
    --language=C     
    --keyword=_ --keyword=N_ --keyword=C_:1c,2 --keyword=NC_:1c,2 
    --keyword=gettext --keyword=dgettext:2
    --keyword=dcgettext:2 --keyword=ngettext:1,2
    --keyword=dngettext:2,3 --keyword=dcngettext:2,3
    --keyword=gettext_noop --keyword=pgettext:1c,2
    --keyword=dpgettext:2c,3 --keyword=dcpgettext:2c,3
    --keyword=npgettext:1c,2,3 --keyword=dnpgettext:2c,3,4 
    --keyword=dcnpgettext:2c,3,4.
    )

SET(MANAGE_TRANSLATION_MSGFMT_OPTIONS 
    "--check" CACHE STRING "msgfmt options"
    )
SET(MANAGE_TRANSLATION_MSGMERGE_OPTIONS 
    "--indent" "--update" "--sort-by-file" "--backup=none" 
    CACHE STRING "msgmerge options"
    )
SET(MANAGE_TRANSLATION_XGETTEXT_OPTIONS 
    ${XGETTEXT_OPTIONS_C}
    CACHE STRING "xgettext options"
    )

FUNCTION(MANAGE_TRANSLATION_GETTEXT_POT_FILES_SET value)
    SET(MANAGE_TRANSLATION_GETTEXT_POT_FILES "${value}" CACHE INTERNAL "POT files")
ENDFUNCTION()

FUNCTION(MANAGE_TRANSLATION_GETTEXT_POT_FILES_ADD)
    LIST(APPEND MANAGE_TRANSLATION_GETTEXT_POT_FILES ${ARGN})
    MANAGE_TRANSLATION_GETTEXT_POT_FILES_SET("${MANAGE_TRANSLATION_GETTEXT_POT_FILES}")
ENDFUNCTION()

FUNCTION(MANAGE_TRANSLATION_GETTEXT_PO_FILES_SET value)
    SET(MANAGE_TRANSLATION_GETTEXT_PO_FILES "${value}" CACHE INTERNAL "PO files")
ENDFUNCTION()

FUNCTION(MANAGE_TRANSLATION_GETTEXT_PO_FILES_ADD)
    LIST(APPEND MANAGE_TRANSLATION_GETTEXT_PO_FILES ${ARGN})
    MANAGE_TRANSLATION_GETTEXT_PO_FILES_SET("${MANAGE_TRANSLATION_GETTEXT_PO_FILES}")
ENDFUNCTION()

FUNCTION(MANAGE_TRANSLATION_GETTEXT_MO_FILES_SET value)
    SET(MANAGE_TRANSLATION_GETTEXT_MO_FILES "${value}" CACHE INTERNAL "MO files")
ENDFUNCTION()

FUNCTION(MANAGE_TRANSLATION_GETTEXT_MO_FILES_ADD)
    LIST(APPEND MANAGE_TRANSLATION_GETTEXT_MO_FILES ${ARGN})
    MANAGE_TRANSLATION_GETTEXT_MO_FILES_SET("${MANAGE_TRANSLATION_GETTEXT_MO_FILES}")
ENDFUNCTION()

FUNCTION(MANAGE_TRANSLATION_LOCALES_SET value)
    SET(MANAGE_TRANSLATION_LOCALES "${value}" CACHE INTERNAL "Translation Locales")
ENDFUNCTION()

FUNCTION(MANAGE_GETTEXT_INIT)
    IF(DEFINED MANAGE_GETTEXT_SUPPORT)
	RETURN()
    ENDIF()
    INCLUDE(ManageArchive)
    INCLUDE(ManageDependency)
    MANAGE_DEPENDENCY(BUILD_REQUIRES GETTEXT REQUIRED)
    MANAGE_DEPENDENCY(BUILD_REQUIRES FINDUTILS REQUIRED)
    MANAGE_DEPENDENCY(REQUIRES GETTEXT REQUIRED)

    FOREACH(_name "xgettext" "msgmerge" "msgfmt" "msginit")
	STRING(TOUPPER "${_name}" _cmd)
	FIND_PROGRAM_ERROR_HANDLING(${_cmd}_EXECUTABLE
	    ERROR_MSG " gettext support is disabled."
	    ERROR_VAR _gettext_dependency_missing
	    VERBOSE_LEVEL ${M_OFF}
	    "${_name}"
	    )
	M_MSG(${M_INFO1} "${_cmd}_EXECUTABLE=${${_cmd}_EXECUTABLE}")
    ENDFOREACH(_name "xgettext" "msgmerge" "msgfmt")

    MANAGE_TRANSLATION_GETTEXT_POT_FILES_SET("")
    IF(gettext_dependency_missing)
	SET(MANAGE_GETTEXT_SUPPORT "0" CACHE INTERNAL "Gettext support")
    ELSE()
	SET(MANAGE_GETTEXT_SUPPORT "1" CACHE INTERNAL "Gettext support")
	MANAGE_TRANSLATION_GETTEXT_PO_FILES_SET("")
	MANAGE_TRANSLATION_GETTEXT_MO_FILES_SET("")
	MANAGE_TRANSLATION_LOCALES_SET("")
    ENDIF()
ENDFUNCTION(MANAGE_GETTEXT_INIT)

SET(MANAGE_POT_FILE_VALID_OPTIONS "SRCS" "DOMAIN_NAME" "PO_DIR" "MO_DIR"
    "MO_LOCALE_DIR" "NO_MO" "LOCALES" "SYSTEM_LOCALES" "XGETTEXT_OPTIONS"
    "MSGMERGE_OPTIONS" "MSGFMT_OPTIONS" "CLEAN" "COMMAND" "DEPENDS"
    )
## Internal
FUNCTION(MANAGE_POT_FILE_SET_VARS potFile)
    VARIABLE_PARSE_ARGN(_o MANAGE_POT_FILE_VALID_OPTIONS ${ARGN})
    SET(cmdList "")
    IF("${_o_COMMAND}" STREQUAL "")
	LIST(APPEND cmdList ${XGETTEXT_EXECUTABLE})
	IF(NOT _o_XGETTEXT_OPTIONS)
	    SET(_o_XGETTEXT_OPTIONS 
		"${MANAGE_TRANSLATION_XGETTEXT_OPTIONS}"
		)
	ENDIF()
	LIST(APPEND cmdList ${_o_XGETTEXT_OPTIONS})
	IF("${_o_SRCS}" STREQUAL "")
	    M_MSG(${M_WARN} 
		"MANAGE_POT_FILE: xgettext: No SRCS for ${potFile}"
		)
	ENDIF()
	LIST(APPEND cmdList -o ${potFile}
	    "--package-name=${PROJECT_NAME}"
	    "--package-version=${PRJ_VER}"
	    "--msgid-bugs-address=${MAINTAINER}"
	    ${_o_SRCS}
	    )
    ELSE()
	SET(cmdList "${_o_COMMAND}")
    ENDIF()
    SET(cmdList "${cmdList}" PARENT_SCOPE)
    SET(srcs "${_o_SRCS}" PARENT_SCOPE)
    SET(depends "${_o_DEPENDS}" PARENT_SCOPE)

    GET_FILENAME_COMPONENT(_potDir "${potFile}" PATH)
    IF("${_o_PO_DIR}" STREQUAL "")
	SET(_o_PO_DIR "${_potDir}")
    ENDIF()
    SET(poDir "${_o_PO_DIR}" PARENT_SCOPE)

    IF("${_o_DOMAIN_NAME}" STREQUAL "")
	GET_FILENAME_COMPONENT(_domainName "${potFile}" NAME_WE)
	SET(domainName "${_domainName}" PARENT_SCOPE)
    ELSE()
	SET(domainName "${_o_DOMAIN_NAME}" PARENT_SCOPE)
    ENDIF()

    IF("${_o_MSGMERGE_OPTIONS}" STREQUAL "")
	SET(_o_MSGMERGE_OPTIONS "${MANAGE_TRANSLATION_MSGMERGE_OPTIONS}")
    ENDIF()
    SET(msgmergeOpts "${_o_MSGMERGE_OPTIONS}" PARENT_SCOPE)

    IF("${_o_MSGFMT_OPTIONS}" STREQUAL "")
	SET(_o_MSGFMT_OPTIONS "${MANAGE_TRANSLATION_MSGFMT_OPTIONS}")
    ENDIF()
    SET(msgfmtOpts "${_o_MSGFMT_OPTIONS}" PARENT_SCOPE)

    IF(DEFINED _o_NO_MO)
	SET(moMode "NO_MO")
    ENDIF()

    IF(DEFINED _o_MO_LOCALE_DIR)
	IF(moMode)
	    M_MSG(${M_ERROR} "MO_LOCALE_DIR cannot be used with ${moMode}")
	ENDIF()
	SET(moLocaleDir "${_o_MO_LOCALE_DIR}" PARENT_SCOPE)
	SET(moMode "MO_LOCALE_DIR")
    ENDIF()

    IF(DEFINED _o_MO_DIR)
	IF(moMode)
	    M_MSG(${M_ERROR} "MO_DIR cannot be used with ${moMode}")
	ENDIF()
	SET(moDir "${_o_MO_DIR}" PARENT_SCOPE)
	SET(moMode "MO_DIR")
    ENDIF()

    ## Default to MO_DIR if none are not specified, 
    IF(NOT moMode)
	SET(moDir "${_o_PO_DIR}" PARENT_SCOPE)
	SET(moMode "MO_DIR")
    ENDIF()
    SET(moMode "${moMode}" PARENT_SCOPE)

    IF(NOT DEFINED _o_CLEAN)
	SET_DIRECTORY_PROPERTIES(PROPERTIES CLEAN_NO_CUSTOM "1")
	SET(allClean 0 PARENT_SCOPE)
    ELSE()
	SET(allCleanVar 1 PARENT_SCOPE)
    ENDIF()
ENDFUNCTION(MANAGE_POT_FILE_SET_VARS)

FUNCTION(MANAGE_POT_FILE_OBTAIN_TARGET_NAME var potFile)
    FILE(RELATIVE_PATH potFileRel ${CMAKE_SOURCE_DIR} ${potFile})
    STRING(REPLACE "/" "_" target "${potFileRel}")
    STRING_PREPEND(target "pot_file_")
    SET(${var} "${target}" PARENT_SCOPE)
ENDFUNCTION(MANAGE_POT_FILE_OBTAIN_TARGET_NAME)

## This function skip target setup when target exists
## Use MANAGE_POT_FILE if you want check and warning
FUNCTION(MANAGE_POT_FILE_INTERNAL showWarning potFile)
    IF(NOT DEFINED MANAGE_GETTEXT_SUPPORT)
	MANAGE_GETTEXT_INIT()
    ENDIF()
    IF(MANAGE_GETTEXT_SUPPORT EQUAL 0)
	RETURN()
    ENDIF()

    ## Whether pot file already exists in MANAGE_TRANSLATION_GETTEXT_POT_FILES
    MANAGE_POT_FILE_OBTAIN_TARGET_NAME(targetName "${potFile}")

    IF(TARGET ${targetName})
	IF(showWarning)
	    M_MSG(${M_WARN} "MANAGE_POT_FILE: Target ${targetName} is already exists, skip")
	ENDIF()
	RETURN()
    ENDIF()

    MANAGE_POT_FILE_SET_VARS("${potFile}" ${ARGN})

    ADD_CUSTOM_TARGET_COMMAND(${targetName}
	OUTPUT ${potFile}
	NO_FORCE
	COMMAND ${cmdList}
	DEPENDS ${srcs} ${depends}
	COMMENT "${potFile}: ${cmdList}"
	VERBATIM
	)
    MANAGE_TRANSLATION_GETTEXT_POT_FILES_ADD("${potFile}")
    SOURCE_ARCHIVE_CONTENTS_ADD("${potFile}" ${srcs} ${depends})
    SET(cleanList "${potFile}")

    SET(_moInstallRoot "${DATA_DIR}/locale")
    ## Not only POT, but also PO and MO as well
    FOREACH(_l ${MANAGE_TRANSLATION_LOCALES})
	## PO file
	SET(_poFile "${poDir}/${_l}.po")
	ADD_CUSTOM_COMMAND(OUTPUT ${_poFile}
	    COMMAND ${CMAKE_BUILD_TOOL} ${targetName}_no_force
	    COMMAND ${CMAKE_COMMAND} 
	    -D cmd=po_make
	    -D "pot=${potFile}"
	    -D "locales=${_l}"
	    -D "options=${msgmergeOpts}"
	    -D "po_dir=${poDir}"
	    -P ${CMAKE_FEDORA_MODULE_DIR}/ManageGettextScript.cmake
	    COMMENT "Create ${_poFile} from ${potFile}"
	    VERBATIM
	    )
	MANAGE_TRANSLATION_GETTEXT_PO_FILES_ADD("${_poFile}")
	SOURCE_ARCHIVE_CONTENTS_ADD("${_poFile}")

	## MO file
	SET(_moInstallDir "${_moInstallRoot}/${_l}/LC_MESSAGES")
	IF(NOT "${moDir}" STREQUAL "")
	    SET(_moFile "${moDir}/${_l}.gmo")
	    FILE(MAKE_DIRECTORY "${moDir}")
	ELSEIF(moLocaleDir)
	    SET(_moFile "${moLocaleDir}/locale/${_l}/LC_MESSAGES/${domainName}.mo")
	    FILE(MAKE_DIRECTORY "${moLocaleDir}/locale/${_l}/LC_MESSAGES")
	ENDIF()

	IF(NOT "${moMode}" STREQUAL "NO_MO")
	    ADD_CUSTOM_COMMAND(OUTPUT ${_moFile}
		COMMAND ${MSGFMT_EXECUTABLE} 
		-o "${_moFile}"
		"${_poFile}"
		DEPENDS ${_poFile}
		)

	    MANAGE_TRANSLATION_GETTEXT_MO_FILES_ADD("${_moFile}")

	    INSTALL(FILES ${_moFile} DESTINATION "${_moInstallDir}"
		RENAME "${domainName}.mo"
		)
	    LIST(APPEND cleanList "${_moFile}")
	ENDIF()

    ENDFOREACH(_l)
    IF(NOT allClean)
	SET_DIRECTORY_PROPERTIES(PROPERTIES ADDITIONAL_MAKE_CLEAN_FILES "${cleanList}")
    ENDIF()
ENDFUNCTION(MANAGE_POT_FILE_INTERNAL)

FUNCTION(MANAGE_POT_FILE potFile)
    MANAGE_POT_FILE_INTERNAL(1 "${potFile}" ${ARGN})
ENDFUNCTION(MANAGE_POT_FILE)

SET(MANAGE_GETTEXT_LOCALES_VALID_OPTIONS "WORKING_DIRECTORY" "LOCALES" "SYSTEM_LOCALES" "DETECT_PO_DIR" "SRCS")
FUNCTION(MANAGE_GETTEXT_LOCALES localeListVar)
    VARIABLE_PARSE_ARGN(_o MANAGE_GETTEXT_LOCALES_VALID_OPTIONS ${ARGN})
    SET(_detectedPoDir "NOTFOUND")
    IF(NOT "${_o_LOCALES}" STREQUAL "")
	## Locale is defined
    ELSEIF(DEFINED _o_SYSTEM_LOCALES)
	EXECUTE_PROCESS(
	    COMMAND ls -1 /usr/share/locale/
	    COMMAND grep -e "^[a-z]*\\(_[A-Z]*\\)\\?\\(@.*\\)\\?$"
	    COMMAND sort -u 
	    COMMAND xargs 
	    COMMAND sed -e "s/ /;/g"
	    OUTPUT_VARIABLE _o_LOCALES
	    OUTPUT_STRIP_TRAILING_WHITESPACE
	    )
    ELSE()
	IF("${_o_WORKING_DIRECTORY}" STREQUAL "")
	    SET(_o_WORKING_DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}")
	ENDIF()

	## LOCALES is not specified, detect now
	EXECUTE_PROCESS(
	    COMMAND find . -name "*.po"
	    COMMAND sed -e "s|^\\./||"
	    COMMAND sort -u
	    COMMAND xargs
	    COMMAND sed -e "s/ /;/g"
	    WORKING_DIRECTORY "${_o_WORKING_DIRECTORY}"
	    OUTPUT_VARIABLE _poFileList
	    OUTPUT_STRIP_TRAILING_WHITESPACE
	    )
	IF("${_poFileList}" STREQUAL "")
	    M_MSG(${M_ERROR} "MANAGE_GETTEXT_LOCALES: Failed to find any .po files. Please either provide .po files, or specify SYSTEM_LOCALES or LOCALES")
	ENDIF()
	MANAGE_FILE_COMMON_DIR(_detectedPoDir ${_poFileList})

	## Empty _detectedPoDir means the PO files are in current directory
	IF("${_detectedPoDir}" STREQUAL "")
	    SET(_commonPath "")
	ELSE()
	    GET_FILENAME_COMPONENT(_commonPath "${_o_WORKING_DIRECTORY}/${_detectedPoDir}" ABSOLUTE)
	ENDIF()
	FOREACH(_poFile ${_poFileList})
	    IF("${_commonPath}" STREQUAL "")
		SET(_rF "${_poFile}")
	    ELSE()
		GET_FILENAME_COMPONENT(_filePath "${_poFile}" ABSOLUTE)
		FILE(RELATIVE_PATH _rF "${_commonPath}" "${_filePath}")
	    ENDIF()
	    LOCALE_IN_PATH(_l "${_rF}")
	    IF(NOT "${_l}" STREQUAL "")
		LIST(APPEND _o_LOCALES "${_l}")
	    ENDIF()
	ENDFOREACH()

	IF("${_o_LOCALES}" STREQUAL "")
	    ## Failed to find any locale
	    M_MSG(${M_ERROR} "MANAGE_GETTEXT_LOCALES: Failed to detect locales. Please either provide .po files, or specify SYSTEM_LOCALES or  LOCALES")
	ENDIF()
	LIST(REMOVE_DUPLICATES _o_LOCALES)
	LIST(SORT _o_LOCALES)
    ENDIF()
    MANAGE_TRANSLATION_LOCALES_SET("${_o_LOCALES}")
    SET(${localeListVar} "${_o_LOCALES}" PARENT_SCOPE)

    ## Return detected po dir if requested
    IF(NOT "${_o_DETECT_PO_DIR}" STREQUAL "")
	SET(${_o_DETECT_PO_DIR} "${detectedPoDir}" PARENT_SCOPE)
    ENDIF()
ENDFUNCTION(MANAGE_GETTEXT_LOCALES)

SET(MANAGE_GETTEXT_VALID_OPTIONS ${MANAGE_POT_FILE_VALID_OPTIONS} "ALL" "POT_FILE")
FUNCTION(MANAGE_GETTEXT)
    IF(NOT DEFINED MANAGE_GETTEXT_SUPPORT)
	MANAGE_GETTEXT_INIT()
    ENDIF()

    VARIABLE_PARSE_ARGN(_o MANAGE_GETTEXT_VALID_OPTIONS ${ARGN})
    IF(DEFINED _o_ALL)
	SET(_all "ALL")
    ELSE()
	SET(_all "")
    ENDIF(DEFINED _o_ALL)

    VARIABLE_TO_ARGN(_gettext_locales_argn _o MANAGE_GETTEXT_LOCALES_VALID_OPTIONS)
    IF("${MANAGE_TRANSLATION_LOCALES}" STREQUAL "")
	MANAGE_GETTEXT_LOCALES(_locales ${_gettext_locales_argn})
    ENDIF()

    ## Determine the pot files
    VARIABLE_TO_ARGN(_addPotFileOptList _o MANAGE_POT_FILE_VALID_OPTIONS)
    IF(NOT "${_o_POT_FILE}" STREQUAL "")
	### pot file is specified
	MANAGE_POT_FILE("${_o_POT_FILE}" ${_addPotFileOptList})
    ELSE()
	### pot file is not specified
	IF("${MANAGE_TRANSLATION_GETTEXT_POT_FILES}" STREQUAL "")
	    #### No previous pot files
	    SET(_o_POT_FILE "${CMAKE_CURRENT_BINARY_DIR}/${PROJECT_NAME}.pot")
	    MANAGE_POT_FILE("${_o_POT_FILE}" ${_addPotFileOptList})
	ELSE()
	    FOREACH(_potFile ${MANAGE_TRANSLATION_GETTEXT_POT_FILES})
		MANAGE_POT_FILE_INTERNAL(0 "${_potFile}" ${_addPotFileOptList})
	    ENDFOREACH()
	ENDIF()
    ENDIF()

    ## Target translation
    ADD_CUSTOM_TARGET(translations ${_all}
	COMMENT "translations: Making translations"
	)

    ## Target pot_files 
    ## PO depends on POT, so no need to put ALL here
    ADD_CUSTOM_TARGET(pot_files
	COMMENT "pot_files: ${MANAGE_TRANSLATION_GETTEXT_POT_FILES}"
	)

    ## Depends on pot_file targets instead of pot files themselves
    ## Otherwise it won't build when pot files is in sub CMakeLists.txt
    FOREACH(potFile ${MANAGE_TRANSLATION_GETTEXT_POT_FILES})
	MANAGE_POT_FILE_OBTAIN_TARGET_NAME(targetName "${potFile}")
	ADD_DEPENDENCIES(pot_files ${targetName}_no_force)
    ENDFOREACH(potFile)

    ## Target update_po 
    ADD_CUSTOM_TARGET(update_po
	DEPENDS ${MANAGE_TRANSLATION_GETTEXT_PO_FILES}
	COMMENT "update_po: ${MANAGE_TRANSLATION_GETTEXT_PO_FILES}"
	)
    ADD_DEPENDENCIES(update_po pot_files)

    ## Target gmo_files 
    IF(MANAGE_TRANSLATION_GETTEXT_MO_FILES)
	ADD_CUSTOM_TARGET(gmo_files
	    DEPENDS ${MANAGE_TRANSLATION_GETTEXT_MO_FILES}
	    COMMENT "gmo_files: ${MANAGE_TRANSLATION_GETTEXT_MO_FILES}"
	    )
    ENDIF()

    IF(TARGET gmo_files)
	ADD_DEPENDENCIES(gmo_files update_po)
	ADD_DEPENDENCIES(translations gmo_files)
    ELSE()
	ADD_DEPENDENCIES(translations update_po)
    ENDIF()

ENDFUNCTION(MANAGE_GETTEXT)

SET(MANAGE_GETTEXT_DETECT_POT_DIR_VALID_OPTIONS "WORKING_DIRECTORY")
FUNCTION(MANAGE_GETTEXT_DETECT_POT_DIR potDirVar)
    VARIABLE_PARSE_ARGN(_o MANAGE_GETTEXT_DETECT_POT_DIR_VALID_OPTIONS ${ARGN})
    SET(detectedPotDir "NOTFOUND")
    IF("${_o_WORKING_DIRECTORY}" STREQUAL "")
	SET(_o_WORKING_DIRECTORY "${CMAKE_HOME_DIR}")
    ENDIF()
    EXECUTE_PROCESS(
	COMMAND find . -name "*.pot"
	COMMAND sed -e "s|^\\./||"
	COMMAND sort -u
	COMMAND xargs
	COMMAND sed -e "s/ /;/g"
	WORKING_DIRECTORY "${_o_WORKING_DIRECTORY}"
	OUTPUT_VARIABLE potFileList
	OUTPUT_STRIP_TRAILING_WHITESPACE
	)
    LIST(LENGTH potFileList potFileListLen)
    IF( potFileListLen EQUAL 0 )
	## NOT_FOUND
    ELSEIF( potFileListLen EQUAL 1 )
	GET_FILENAME_COMPONENT(detectedPotDir "${potFileList}" PATH)
    ELSE()
	MANAGE_FILE_COMMON_DIR(detectedPotDir ${potFileList})
    ENDIF()
    SET(${potDirVar} "${detectedPotDir}" PARENT_SCOPE)
ENDFUNCTION(MANAGE_GETTEXT_DETECT_POT_DIR)

FUNCTION(LOCALE_PARSE_STRING language script country modifier str)
    SET(_s "")
    SET(_c "")
    SET(_m "")
    IF("${str}" MATCHES "(.*)@(.*)")
	SET(_m "${CMAKE_MATCH_2}")
	SET(_str "${CMAKE_MATCH_1}")
    ELSE()
	SET(_str "${str}")
    ENDIF()
    STRING(REPLACE "-" "_" _str "${_str}")
    STRING_SPLIT(_lA "_" "${_str}")
    LIST(LENGTH _lA _lLen)
    LIST(GET _lA 0 _l)
    IF(_lLen GREATER 2)
	LIST(GET _lA 2 _c)
    ENDIF()
    IF(_lLen GREATER 1)
	LIST(GET _lA 1 _x)
	IF("${_x}" MATCHES "[A-Z][a-z][a-z][a-z]")
	    SET(_s "${_x}")
	ELSE()
	    SET(_c "${_x}")
	ENDIF()
    ENDIF()

    # Make sure the language is in the list
    IF(NOT DEFINED ZANATA_SUGGEST_COUNTRY_${_l}__)
	# empty language means invalid languages
	SET(_l "")
	SET(_s "")
	SET(_c "")
	SET(_m "")
    ENDIF()

    SET(${language} "${_l}" PARENT_SCOPE)
    SET(${script} "${_s}" PARENT_SCOPE)
    SET(${country} "${_c}" PARENT_SCOPE)
    SET(${modifier} "${_m}" PARENT_SCOPE)
ENDFUNCTION(LOCALE_PARSE_STRING)

FUNCTION(LOCALE_IN_PATH var path)
    GET_FILENAME_COMPONENT(_token "${path}" NAME_WE)
    LOCALE_PARSE_STRING(language script country modifier "${_token}")
    IF(NOT "${language}" STREQUAL "")
	SET(${var} "${_token}" PARENT_SCOPE)
	RETURN()
    ENDIF()

    GET_FILENAME_COMPONENT(_dir "${path}" PATH)
    STRING_SPLIT(dirA "/" "${_dir}")
    LIST(LENGTH dirA dirALen)
    MATH(EXPR i ${dirALen}-1)
    WHILE(NOT i LESS 0)
	LIST(GET dirA ${i} _token)
	LOCALE_PARSE_STRING(language script country modifier "${_token}")
	IF(NOT "${language}" STREQUAL "")
	    SET(${var} "${_token}" PARENT_SCOPE)
	    RETURN()
	ENDIF()
	MATH(EXPR i ${i}-1)
    ENDWHILE()

    SET(${var} "" PARENT_SCOPE)
ENDFUNCTION(LOCALE_IN_PATH)
