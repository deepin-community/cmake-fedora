# Test for CmakeFedoraKoji
INCLUDE(test/testCommon.cmake)
INCLUDE(ManageMessage)

SET(CMAKE_FEDORA_KOJI_CMD "scripts/cmake-fedora-koji")

MESSAGE("CMAKE_FEDORA_KOJI_HELP: ")
EXECUTE_PROCESS(COMMAND ${CMAKE_FEDORA_KOJI_CMD}
    OUTPUT_VARIABLE v
    OUTPUT_STRIP_TRAILING_WHITESPACE
    )
IF(NOT v MATCHES "cmake-fedora-koji")
    MESSAGE(SEND_ERROR "Failed to print help.")
ENDIF(NOT v MATCHES "cmake-fedora-koji")

FUNCTION(CMAKE_FEDORA_KOJI_TEST expected cmd)
    MESSAGE("CMAKE_FEDORA_KOJI_TEST: ${cmd}_${ARGN}")
    EXECUTE_PROCESS(COMMAND ${CMAKE_FEDORA_KOJI_CMD}
        ${cmd} ${ARGN}
        OUTPUT_VARIABLE v
        OUTPUT_STRIP_TRAILING_WHITESPACE
	    )
    TEST_STR_MATCH(v "${expected}")
ENDFUNCTION(CMAKE_FEDORA_KOJI_TEST)

CMAKE_FEDORA_KOJI_TEST("27\n26\n23" "ver" "f27" "f26" "f23")
CMAKE_FEDORA_KOJI_TEST("epel7\nel6" "branch" "el7" "el6")
CMAKE_FEDORA_KOJI_TEST("master\nf25\nepel7\nel6" "git-branch" "rawhide" "f25" "el7" "el6")
CMAKE_FEDORA_KOJI_TEST("f26-candidate\nepel7-candidate\nel6-candidate" "target" "f26" "el7" "el6")
