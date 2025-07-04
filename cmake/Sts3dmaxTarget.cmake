#----------------------------------------------------------------------------------#
#//////////////////////////////////////////////////////////////////////////////////#
#----------------------------------------------------------------------------------#
#
#  Copyright (C) 2017, StepToSky
#  All rights reserved.
#
#  Redistribution and use in source and binary forms, with or without
#  modification, are permitted provided that the following conditions are met:
#
#  1.Redistributions of source code must retain the above copyright notice, this
#    list of conditions and the following disclaimer.
#  2.Redistributions in binary form must reproduce the above copyright notice,
#    this list of conditions and the following disclaimer in the documentation
#    and / or other materials provided with the distribution.
#  3.Neither the name of StepToSky nor the names of its
#    contributors may be used to endorse or promote products derived from
#    this software without specific prior written permission.
#
#  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
#  ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
#  WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
#  DISCLAIMED.IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR
#  ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
#  (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
#  LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
#  ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
#  (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
#  SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#
#  Contacts: www.steptosky.com
#
#----------------------------------------------------------------------------------#
#
# StepToSky 3DsMax terget setup.
#
# Version 1.0.0 (03.04.2017)
#
#----------------------------------------------------------------------------------#
#
#	Usage example:
#
#		# specify the folder where this module is.
#		list(APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_SOURCE_DIR}/cmake")
#		
#		include(Sts3dmaxTarget)
#		SETUP_MAX_TERGET(SDK_TARGET "3DsMaxSdk2008" 3DMAX_VERSION "2008")
#		SETUP_MAX_TERGET(SDK_TARGET "3DsMaxSdk2009" 3DMAX_VERSION "2009")
#		SETUP_MAX_TERGET(SDK_TARGET "3DsMaxSdk2010" 3DMAX_VERSION "2010")
#
#----------------------------------------------------------------------------------#
#//////////////////////////////////////////////////////////////////////////////////#
#----------------------------------------------------------------------------------#

include(CMakeParseArguments)

function(SETUP_MAX_TARGET)

	#set(options OPTIONAL FAST)
	#set(multiValueArgs TARGETS CONFIGURATIONS)
	set(oneValueArgs SDK_TARGET 3DMAX_VERSION)
	cmake_parse_arguments(SETUP_MAX_TARGET "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN} )

	# Check if we have the required dependencies for this version
	if(MAX_SDK_PATH AND (XPLNOBJ_INCLUDE_DIR AND XPLNOBJ_LIBRARY))
		message(STATUS "3DsMax + ${SETUP_MAX_TARGET_3DMAX_VERSION}")
		set (PROJECT "3DsMax-${SETUP_MAX_TARGET_3DMAX_VERSION}")
		set (OUTPUT_NAME "3DsMax${SETUP_MAX_TARGET_3DMAX_VERSION}-XplnObj")
		
		#--------------------------------------------------------------------------#
		#//////////////////////////////////////////////////////////////////////////#
		#--------------------------------------------------------------------------#
		# compiler 

		if (${CMAKE_CXX_COMPILER_ID} STREQUAL MSVC)
			add_definitions (/W4)
			add_definitions (-D_USRDLL)
			add_definitions (-D_WIN64)
			add_definitions (-D_CRT_SECURE_NO_DEPRECATE)
			add_definitions (-DISOLATION_AWARE_ENABLED=1)
			add_definitions (-DNOMINMAX)  # Prevent min/max macro conflicts
			add_definitions (-DWIN32_LEAN_AND_MEAN)  # Reduce Windows header bloat
		else ()
			message (FATAL_ERROR "<${PROJECT}> Unknown compiler")
		endif ()

		# Add version-specific definitions
		string(REGEX MATCH "([0-9]+)" MAX_VERSION_MAJOR "${SETUP_MAX_TARGET_3DMAX_VERSION}")
		if(MAX_VERSION_MAJOR)
			add_definitions(-DMAX_VERSION_MAJOR=${MAX_VERSION_MAJOR})
		endif()

		#--------------------------------------------------------------------------#
		#//////////////////////////////////////////////////////////////////////////#
		#--------------------------------------------------------------------------#
		# project files

		file(GLOB_RECURSE CM_FILES 
			"${CMAKE_SOURCE_DIR}/src/*.h"
			"${CMAKE_SOURCE_DIR}/src/*.hpp" 
			"${CMAKE_SOURCE_DIR}/src/*.inl" 
			"${CMAKE_SOURCE_DIR}/src/*.cpp"
			"${CMAKE_SOURCE_DIR}/src/*.rc"
			"${CMAKE_SOURCE_DIR}/src/*.txt"
			"${CMAKE_SOURCE_DIR}/include/*.h" 
			"${CMAKE_SOURCE_DIR}/include/*.inl" 
			"${CMAKE_SOURCE_DIR}/include/*.cpp"
			
			"${CMAKE_SOURCE_DIR}/doc/*"
		)

		include(StsGroupFiles)
		groupFiles("${CM_FILES}")

		list(APPEND CM_FILES "${CMAKE_SOURCE_DIR}/readme.md")
		source_group("doc" FILES "${CMAKE_SOURCE_DIR}/readme.md")

		#--------------------------------------------------------------------------#
		#//////////////////////////////////////////////////////////////////////////#
		#--------------------------------------------------------------------------#
		# include/link directories

		include_directories (${CMAKE_SOURCE_DIR}/include)
		include_directories (${CMAKE_SOURCE_DIR}/src)
		include_directories (${MAX_SDK_PATH}/include)
		
		if(XPLNOBJ_INCLUDE_DIR)
			include_directories (${XPLNOBJ_INCLUDE_DIR})
		endif()

		# Add additional include directories for utility libraries
		include_directories (${CMAKE_SOURCE_DIR}/src/3rdParties/json/single_include)

		#--------------------------------------------------------------------------#
		#//////////////////////////////////////////////////////////////////////////#
		#--------------------------------------------------------------------------#
		
		add_library(${PROJECT} SHARED ${CM_FILES})
		
		# Link 3ds Max SDK libraries
		target_link_libraries(${PROJECT} 
			${MAX_SDK_PATH}/lib/x64/core.lib
			${MAX_SDK_PATH}/lib/x64/maxutil.lib
			${MAX_SDK_PATH}/lib/x64/mesh.lib
			${MAX_SDK_PATH}/lib/x64/mnmath.lib
			${MAX_SDK_PATH}/lib/x64/paramblk2.lib
			${MAX_SDK_PATH}/lib/x64/bmm.lib
		)
		
		# Link XplnObj library if available
		if(XPLNOBJ_LIBRARY)
			target_link_libraries(${PROJECT} ${XPLNOBJ_LIBRARY})
		endif()
		
		# Link Windows libraries
		target_link_libraries(${PROJECT} 
			optimized Winhttp debug Winhttp
			version.lib
			comctl32.lib
		)

		#--------------------------------------------------------------------------#
		#//////////////////////////////////////////////////////////////////////////#
		#--------------------------------------------------------------------------#
				
		set_target_properties(${PROJECT} PROPERTIES DEBUG_OUTPUT_NAME  ${OUTPUT_NAME})
		set_target_properties(${PROJECT} PROPERTIES RELEASE_OUTPUT_NAME  ${OUTPUT_NAME})
		set_target_properties(${PROJECT} PROPERTIES SUFFIX  ".dlu")
		set_target_properties(${PROJECT} PROPERTIES DEBUG_POSTFIX "-x64")
		set_target_properties(${PROJECT} PROPERTIES RELEASE_POSTFIX "-x64")
		
		# Set additional properties for modern compatibility
		set_target_properties(${PROJECT} PROPERTIES
			CXX_STANDARD 17
			CXX_STANDARD_REQUIRED ON
		)
		
		#--------------------------------------------------------------------------#
		#//////////////////////////////////////////////////////////////////////////#
		#--------------------------------------------------------------------------#

		install(TARGETS ${PROJECT} RUNTIME DESTINATION "$<CONFIG>" CONFIGURATIONS "Release")

		#--------------------------------------------------------------------------#
		#//////////////////////////////////////////////////////////////////////////#
		#--------------------------------------------------------------------------#
		
	else()
		message(STATUS "3DsMax - ${SETUP_MAX_TARGET_3DMAX_VERSION} (skipped - missing dependencies)")
	endif()
	
endfunction(SETUP_MAX_TARGET)

#----------------------------------------------------------------------------------#
#//////////////////////////////////////////////////////////////////////////////////#
#----------------------------------------------------------------------------------#