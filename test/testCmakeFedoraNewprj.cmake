# Test for CmakeFedoraFedpkg
INCLUDE(test/testCommon.cmake)
INCLUDE(ManageMessage)

SET(CMAKE_FEDORA_NEWPRJ_CMD "${CTEST_HOME_DIR}/scripts/cmake-fedora-newprj")

MESSAGE("CMAKE_FEDORA_NEWPRJ_HELP: ")
EXECUTE_PROCESS(COMMAND ${CMAKE_FEDORA_NEWPRJ_CMD}
    OUTPUT_VARIABLE v
    OUTPUT_STRIP_TRAILING_WHITESPACE
    )
IF(NOT v MATCHES "cmake-fedora-newprj")
    MESSAGE(SEND_ERROR "Failed to print help.")
ENDIF(NOT v MATCHES "cmake-fedora-newprj")

FUNCTION(CMAKE_FEDORA_NEWPRJ_TEST projectName)
    MESSAGE("CMAKE_FEDORA_NEWPRJ: ${projectName}")
    SET(projectDir "/tmp/cmake-fedora-newprj-test/${projectName}")
    IF(EXISTS "${projectDir}")
	FILE(REMOVE_RECURSE "${projectDir}")
    ENDIF(EXISTS "${projectDir}")

    FILE(MAKE_DIRECTORY "${projectDir}")
    EXECUTE_PROCESS(COMMAND ${CMAKE_FEDORA_NEWPRJ_CMD} "${projectName}"
	RESULT_VARIABLE failVar
	OUTPUT_VARIABLE outVar
	ERROR_VARIABLE  errVar
	WORKING_DIRECTORY "${projectDir}"
	)
    IF(failVar)
	MESSAGE(SEND_ERROR "${failVar}: ${errVar} |out=${outVar}|")
    ENDIF(failVar)

    ## Install a hello world script
    FILE(WRITE "${projectDir}/hello_world.sh" "#!/bin/bash\necho 'Hello World!'")
    EXECUTE_PROCESS(COMMAND sed -i -e "s/#SET(BUILD_ARCH \"noarch\")/SET(BUILD_ARCH \"noarch\")/" "${projectDir}/CMakeLists.txt")
    FILE(APPEND "${projectDir}/CMakeLists.txt" "INSTALL(PROGRAMS hello_world.sh DESTINATION /usr/bin)")

    
    MESSAGE("CMAKE_FEDORA_NEWPRJ: ${projectName} cmake .")
    EXECUTE_PROCESS(COMMAND ${CMAKE_COMMAND} "."
	RESULT_VARIABLE failVar
	OUTPUT_VARIABLE outVar
	ERROR_VARIABLE  errVar
	WORKING_DIRECTORY "${projectDir}"
	)
    IF(failVar)
	MESSAGE(SEND_ERROR "${failVar}: ${errVar} |out=${outVar}|")
    ENDIF(failVar)

    MESSAGE("CMAKE_FEDORA_NEWPRJ: ${projectName} make rpm")
    EXECUTE_PROCESS(COMMAND make rpm
	RESULT_VARIABLE failVar
	OUTPUT_VARIABLE outVar
	ERROR_VARIABLE  errVar
	WORKING_DIRECTORY "${projectDir}"
	)
    IF(failVar)
	MESSAGE(SEND_ERROR "${failVar}: ${errVar} |out=${outVar}|")
    ENDIF(failVar)
ENDFUNCTION(CMAKE_FEDORA_NEWPRJ_TEST) 

CMAKE_FEDORA_NEWPRJ_TEST("testProj")

