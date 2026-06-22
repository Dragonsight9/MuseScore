#!/usr/bin/env bash
# Inject portable x86-64 / SSE3 flags into MuseScore's official Linux CI build.
# Run from the MuseScore repo root AFTER buildscripts/ci/linux/setup.sh.

set -euo pipefail

CPU_FLAGS="-march=x86-64 -mtune=generic -msse3"

echo "=== Applying SSE3 CPU baseline (no SSE4) ==="
echo "Flags: ${CPU_FLAGS}"

if [[ -f "${HOME}/build_tools/environment.sh" ]]; then
  cat >> "${HOME}/build_tools/environment.sh" <<EOF

# KeyGenius VPS: avoid SSE4+ instructions in MuseScore binaries
export CFLAGS="\${CFLAGS:-} ${CPU_FLAGS}"
export CXXFLAGS="\${CXXFLAGS:-} ${CPU_FLAGS}"
export CMAKE_C_FLAGS="\${CMAKE_C_FLAGS:-} ${CPU_FLAGS}"
export CMAKE_CXX_FLAGS="\${CMAKE_CXX_FLAGS:-} ${CPU_FLAGS}"
EOF
  echo "Patched ${HOME}/build_tools/environment.sh"
else
  echo "WARNING: ${HOME}/build_tools/environment.sh not found" >&2
fi

cat > build_overrides.cmake <<EOF
# KeyGenius VPS: portable CPU baseline
set(CMAKE_C_FLAGS "\${CMAKE_C_FLAGS} ${CPU_FLAGS}" CACHE STRING "" FORCE)
set(CMAKE_CXX_FLAGS "\${CMAKE_CXX_FLAGS} ${CPU_FLAGS}" CACHE STRING "" FORCE)
set(CMAKE_C_FLAGS_RELEASE "\${CMAKE_C_FLAGS_RELEASE} -O2" CACHE STRING "" FORCE)
set(CMAKE_CXX_FLAGS_RELEASE "\${CMAKE_CXX_FLAGS_RELEASE} -O2" CACHE STRING "" FORCE)
set(MUSE_COMPILE_USE_UNITY OFF CACHE BOOL "" FORCE)
EOF

{
  echo "CFLAGS=${CPU_FLAGS}"
  echo "CXXFLAGS=${CPU_FLAGS}"
  echo "CMAKE_C_FLAGS=${CPU_FLAGS}"
  echo "CMAKE_CXX_FLAGS=${CPU_FLAGS}"
} >> "${GITHUB_ENV}"

echo "Created build_overrides.cmake"
