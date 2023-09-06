# Deep Test for CmakeFedoraFedpkg
INCLUDE(test/testCommon.cmake)
INCLUDE(ManageMessage)

GET_FILENAME_COMPONENT(CMAKE_FEDORA_FEDPKG_CMD "scripts/cmake-fedora-fedpkg" REALPATH)

MESSAGE("CMAKE_FEDORA_FEDPKG Built and Pushed: ")
## Download cmake-fedora-2.7.1
SET(CMAKE_FEDORA_TEST_VERREL "2.7.1-1")
SET(CMAKE_FEDORA_TEST_SRPM "cmake-fedora-${CMAKE_FEDORA_TEST_VERREL}.el7.src.rpm")
FILE(DOWNLOAD "http://dl.fedoraproject.org/pub/epel/7/SRPMS/c/${CMAKE_FEDORA_TEST_SRPM}"
    "${CMAKE_FEDORA_TMP_DIR}/download/${CMAKE_FEDORA_TEST_SRPM}")
EXECUTE_PROCESS(COMMAND ${CMAKE_FEDORA_FEDPKG_CMD} download/${CMAKE_FEDORA_TEST_SRPM} epel7
    RESULT_VARIABLE ret
    OUTPUT_STRIP_TRAILING_WHITESPACE
    WORKING_DIRECTORY "${CMAKE_FEDORA_TMP_DIR}"
    )
IF(NOT ret EQUAL 0)
    MESSAGE("ret=${ret}")
    MESSAGE(SEND_ERROR "Failed cmake-fedora-fedpkg download/${CMAKE_FEDORA_TEST_SRPM}")
ENDIF()

