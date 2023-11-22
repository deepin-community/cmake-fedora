# - Manage targets and output files.
#
# Included Modules:
#   - ManageVariable
#
# Defines following functions:
#   ADD_CUSTOM_TARGET_COMMAND(<target> OUTPUT <file1> ...
#     [ALL] [NO_FORCE] COMMAND <command1> ...
#     [<addCustomTargetOpt> ...]
#   )
#   - Combine ADD_CUSTOM_TARGET and ADD_CUSTOM_COMMAND.
#     This command is handy if you want a target that always refresh
#     the output files without writing the same build recipes
#     in separate ADD_CUSTOM_TARGET and ADD_CUSTOM_COMMAND.
#
#     If you also want a target that run only if output files 
#     do not exist or outdated. Specify "NO_FORCE".
#     The target for that will be "<target>_no_force".
#     * Parameters:
#       + target: target for this command
#       + OUTPUT file1 ... : Files to be outputted by this command
#       + ALL: (Optional) The target is built with target 'all'
#       + NO_FORCE: (Optional) Produce a target that run only if 
#         output files do not exist or outdated. 
#       + COMMAND command ... : Command to be run. 
#       + addCustomTargetOpt ...: ADD_CUSTOM_TARGET.options.
#     * Targets:
#       + <target>: Target to be invoke.
#

IF(DEFINED _MANAGE_TARGET_CMAKE_)
    RETURN()
ENDIF(DEFINED _MANAGE_TARGET_CMAKE_)
SET(_MANAGE_TARGET_CMAKE_ "DEFINED")
INCLUDE(ManageVariable)
FUNCTION(ADD_CUSTOM_TARGET_COMMAND target)
    SET(_validOptions "OUTPUT" "ALL" "NO_FORCE" "COMMAND")
    VARIABLE_PARSE_ARGN(_opt _validOptions ${ARGN})
    IF(DEFINED _opt_ALL)
	SET(_all "ALL")
    ELSE(DEFINED _opt_ALL)
	SET(_all "")
    ENDIF(DEFINED _opt_ALL)

    ADD_CUSTOM_TARGET(${target} ${_all}
	COMMAND ${_opt_COMMAND}
	)

    ADD_CUSTOM_COMMAND(OUTPUT ${_opt_OUTPUT} 
	COMMAND ${_opt_COMMAND}
	)

    IF(DEFINED _opt_NO_FORCE)
	ADD_CUSTOM_TARGET(${target}_no_force
	    DEPENDS ${_opt_OUTPUT}
	    )
    ENDIF(DEFINED _opt_NO_FORCE)
ENDFUNCTION(ADD_CUSTOM_TARGET_COMMAND)

