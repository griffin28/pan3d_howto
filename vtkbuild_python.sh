#!/bin/bash

function error
{
    printf "%s\n" "$@" >&2
    exit 1
}

function issue_command
{
    printf "%s\n" "$@"
    "$@"
    return $?
}

function build_vtk
{
    vtk_inst_path="/home/kgriffin/Projects/VisIt/third_party/test/vtk/9.5.2/linux-x86_64_gcc-13.3"

    vopts="-DCMAKE_BUILD_TYPE:STRING=Debug"
    vopts="${vopts} -DCMAKE_INSTALL_PREFIX:PATH=${vtk_inst_path}"
    vopts="${vopts} -DVTK_LEGACY_REMOVE=ON" 
    vopts="${vopts} -DVTK_BUILD_TESTING=OFF" 
    vopts="${vopts} -DVTK_ALL_NEW_OBJECT_FACTORY=ON" 

    # Turn off module groups
    vopts="${vopts} -DVTK_GROUP_ENABLE_Imaging:STRING=DONT_WANT"
    vopts="${vopts} -DVTK_GROUP_ENABLE_MPI:STRING=DONT_WANT"
    vopts="${vopts} -DVTK_GROUP_ENABLE_Qt:STRING=DONT_WANT"
    vopts="${vopts} -DVTK_GROUP_ENABLE_Rendering:STRING=DONT_WANT"
    #vopts="${vopts} -DVTK_GROUP_ENABLE_StandAlone:STRING=DONT_WANT"
    # one of the vtk modules introduced this case for StandALone
    # Probably a mistake, but guard against it anyways as it shows up
    # in the Cache.
    #vopts="${vopts} -DVTK_GROUP_ENABLE_STANDALONE:STRING=DONT_WANT"
    #vopts="${vopts} -DVTK_GROUP_ENABLE_Views:STRING=DONT_WANT"
    vopts="${vopts} -DVTK_GROUP_ENABLE_Web:STRING=YES"
    
    # Python Wheel Build
    vopts="${vopts} -DVTK_ENABLE_WRAPPING=ON" 
    vopts="${vopts} -DVTK_WRAP_PYTHON=ON" 
    vopts="${vopts} -DVTK_WRAP_SERIALIZATION=ON" 
    vopts="${vopts} -DVTK_PYTHON_VERSION=3" 
    vopts="${vopts} -DVTK_WHEEL_BUILD=ON" 
    vopts="${vopts} -DPython3_EXECUTABLE=$(which python)" 

    # Turn on individual modules. dependent modules are turned on automatically
    vopts="${vopts} -DVTK_MODULE_ENABLE_VTK_CommonCore:STRING=YES"
    vopts="${vopts} -DVTK_MODULE_ENABLE_VTK_FiltersFlowPaths:STRING=YES"
    vopts="${vopts} -DVTK_MODULE_ENABLE_VTK_FiltersHybrid:STRING=YES"
    vopts="${vopts} -DVTK_MODULE_ENABLE_VTK_FiltersModeling:STRING=YES"
    vopts="${vopts} -DVTK_MODULE_ENABLE_VTK_FiltersPython:STRING=YES"
    vopts="${vopts} -DVTK_MODULE_ENABLE_VTK_FiltersVerdict:STRING=YES"
    vopts="${vopts} -DVTK_MODULE_ENABLE_VTK_GeovisCore:STRING=YES"
    vopts="${vopts} -DVTK_MODULE_ENABLE_VTK_IOEnSight:STRING=YES"
    vopts="${vopts} -DVTK_MODULE_ENABLE_VTK_IOGeometry:STRING=YES"
    vopts="${vopts} -DVTK_MODULE_ENABLE_VTK_IOLegacy:STRING=YES"
    vopts="${vopts} -DVTK_MODULE_ENABLE_VTK_IOPLY:STRING=YES"
    vopts="${vopts} -DVTK_MODULE_ENABLE_VTK_IOXML:STRING=YES"
    vopts="${vopts} -DVTK_MODULE_ENABLE_VTK_InteractionStyle:STRING=YES"
    vopts="${vopts} -DVTK_MODULE_ENABLE_VTK_RenderingAnnotation:STRING=YES"
    vopts="${vopts} -DVTK_MODULE_ENABLE_VTK_RenderingFreeType:STRING=YES"
    vopts="${vopts} -DVTK_MODULE_ENABLE_VTK_RenderingOpenGL2:STRING=YES"
    vopts="${vopts} -DVTK_MODULE_ENABLE_VTK_RenderingVolumeOpenGL2:STRING=YES"
    vopts="${vopts} -DVTK_MODULE_ENABLE_VTK_libxml2:STRING=YES"
    vopts="${vopts} -DVTK_ENABLE_REMOTE_MODULES:BOOL=OFF"

    # Not in VisIt
    vopts="${vopts} -DVTK_MODULE_ENABLE_VTK_jsoncpp:STRING=YES"
    vopts="${vopts} -DVTK_MODULE_ENABLE_VTK_ViewsCore:STRING=YES"
    vopts="${vopts} -DVTK_MODULE_ENABLE_VTK_exodusII:STRING=YES"
    vopts="${vopts} -DVTK_MODULE_ENABLE_VTK_octree:STRING=YES"
    vopts="${vopts} -DVTK_MODULE_ENABLE_VTK_InfovisLayout:STRING=YES"
    vopts="${vopts} -DVTK_MODULE_ENABLE_VTK_ioss:STRING=YES"
    vopts="${vopts} -DVTK_MODULE_ENABLE_VTK_RenderingVtkJS:STRING=YES"
    vopts="${vopts} -DVTK_MODULE_ENABLE_VTK_DomainsChemistry:STRING=YES"
    vopts="${vopts} -DVTK_MODULE_ENABLE_VTK_SerializationManager:STRING=YES"

    # ANARI
    vopts="${vopts} -DVTK_MODULE_ENABLE_VTK_RenderingAnari:STRING=YES"
    vopts="${vopts} -DVTK_MODULE_ENABLE_VTK_FiltersTexture:STRING=YES"
    vopts="${vopts} -Danari_DIR=/home/kgriffin/Projects/VisIt/third_party/develop/anari/0.14.1/linux-x86_64_gcc-13.3/lib/cmake/anari-0.14.1"

    # OSPRay
    # vopts="${vopts} -DVTK_MODULE_ENABLE_VTK_RenderingRayTracing:STRING=YES"
    # vopts="${vopts} -Dospray_DIR=/home/kgriffin/VisIt/third_party/develop2/ospray/2.8.0/linux-x86_64_gcc-9.4/ospray/lib/cmake/ospray-2.8.0"

    # cd vtk_build_debug/
    CMAKE_BIN="cmake"

    if test -e bv_run_cmake.sh ; then
	rm -f bv_run_cmake.sh
    fi

    echo "\"${CMAKE_BIN}\"" ${vopts} ../VTK > bv_run_cmake.sh
    cat bv_run_cmake.sh
    issue_command bash bv_run_cmake.sh ||  error "VTK 9 configuration failed."

    # build VTK
    printf "%s\n" "Building VTK 9 . . . "
    env DYLD_LIBRARY_PATH=`pwd`/bin cmake --build . -j 16 || \
	error "VTK 9 did not build correctly. Giving up."

    # install VTK
    printf "%s\n" "Installing VTK 9 . . . "
    make install -j 4 || error "VTK 9 did not install correctly."

    printf "%s\n" "Done building VTK 9"
    return 0
}

build_vtk
if [[ $? != 0 ]] ; then
    printf "%s\n" "Unable to build or install VTK" >&2
fi

exit 0
