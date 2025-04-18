#!/bin/bash
# Copyright (C) 2017 Kamil Wilczek, 2025 Pextra Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      https://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
set -euo pipefail
### CONFIG ###
# Format: ["query_string"]=value_type
#
# To get list of available parameters,
# run 'nvidia-smi --help-query-gpu'.
# Replace each '.' with  '_'.
#
declare -A config=(
	["temperature_gpu"]=temperature
	["fan_speed"]=percent
	["pstate"]=absolute
	["memory_used"]=memory
	["memory_free"]=memory
	["utilization_gpu"]=percent
	["utilization_memory"]=percent
	["power_draw"]=power
)
### END CONFIG ###
readonly HOSTNAME="${COLLECTD_HOSTNAME:-$(hostname --fqdn)}"
readonly INTERVAL="${COLLECTD_INTERVAL:-10}"

# Check nvidia-smi
nvidia-smi &> /dev/null
if [ $? -ne 0 ]; then
	echo "nvidia-smi unusable" 1>&2
	exit 1
fi

query_string="pci.bus_id,"
for parameter in "${!config[@]}"; do
	query_string+="${parameter//_/.},"
done

# Query nvidia-smi
gpus_state=$(nvidia-smi --query-gpu="${query_string%,}" --format=csv,noheader,nounits)

# Output collectd PUTVAL commands
while IFS=',' read -r gpu_id "${!config[@]}"; do
	for parameter in "${!config[@]}"; do
		echo "PUTVAL ${HOSTNAME}/cuda-${gpu_id}/${config[$parameter]}-${parameter} interval=$INTERVAL N:${!parameter//P}"
	done
done <<< "${gpus_state// }"
