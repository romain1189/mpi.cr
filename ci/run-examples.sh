#!/bin/sh

set -e

# enable oversubscribing when using newer Open MPI
export OMPI_MCA_rmaps_base_oversubscribe=1
export OMPI_ALLOW_RUN_AS_ROOT=1
export OMPI_ALLOW_RUN_AS_ROOT_CONFIRM=1

EXAMPLES_DIR="examples"
BINARIES_DIR="build"

if [ ! -d "${BINARIES_DIR}" ]
then
  echo "Examples not found in ${BINARIES_DIR}"
  exit 1
fi

if [ $(./src/ext/mpi_vendor) = openmpi ]
then
  FLAGS="--allow-run-as-root"
else
  FLAGS=""
fi

binaries=$(ls ${EXAMPLES_DIR} | sed "s/\\.cr\$//")
num_binaries=$(printf "%d" "$(echo "${binaries}" | wc -w)")

printf "running %d examples\n" ${num_binaries}

num_ok=0
num_failed=0
result="ok"

for binary in ${binaries}
do
  num_proc=$((($(printf "%d" 0x$(openssl rand -hex 1)) % 7) + 2))
  printf "example ${binary} on ${num_proc} processes (${FLAGS}) ... "
  output_file=${binary}_output
  if (mpiexec ${FLAGS} -n ${num_proc} "${BINARIES_DIR}/${binary}" > "${output_file}")
  then
    printf "ok\n"
    num_ok=$((${num_ok} + 1))
  else
    printf "output:\n"
    cat "${output_file}"
    num_failed=$((${num_failed} + 1))
    result="failed"
  fi
  rm -f "${output_file}"
done

printf "\nexample result: ${result}. ${num_ok} passed; ${num_failed} failed\n\n"
exit ${num_failed}
