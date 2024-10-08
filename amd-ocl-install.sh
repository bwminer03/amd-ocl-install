#!/usr/bin/env bash
VERS="0.2"
[ -t 1 ] && . colors

echo
echo "${CYAN}AMD OpenCL Installer v${VERS}${NOCOLOR}"

amdgpuVer=$1
rocmVer=$2

[[ -e /var/run/hive/MINER_RUN ]] && miner_run=1 || miner_run=0

function _check_dist {
    dist=`lsb_release -sr |tr -d "\r\n" |tr -d "."`
    [[ $dist -lt "2004" ]] && echo "${YELLOW}Warning! Version 5.3 and above work only on Ubuntu 20.04 image.${NOCOLOR}"
}

function _uninstall {
	if [[ $miner_run -eq 1 && $(gpu-detect AMD) -gt 0 ]]; then
		echo "${CYAN}> Stopping mining ${NOCOLOR}"
		miner stop > /dev/null 2>&1
	fi
	echo "${CYAN}> Uninstall previous AMDGPU and ROCm OpenCL libs ...${NOCOLOR}"
	apt purge -y hive-opencl-* 1> /dev/null 2> /dev/null
	apt purge -y hive-amdgpu-* hive-rocm-* 1> /dev/null 2> /dev/null
}

function _check {
	[[ -e /opt/amdgpu/VERSION ]]  && cur_amd=`cat /opt/amdgpu/VERSION` || cur_amd="Unknown"
	[[ -e /opt/rocm/VERSION ]]  && cur_rocm=`cat /opt/rocm/VERSION` || cur_rocm="Unknown"
	echo "${CYAN}> Current installed OpenCL libs:  AMDGPU: ${YELLOW}$cur_amd${CYAN}  ROCM: ${YELLOW}$cur_rocm${NOCOLOR}"
#	echo ""
}

function _check_availible {
	echo "${YELLOW}Availible versions of AMDGPU OpenCL:${NOCOLOR}"
	apt-cache search hive-amdgpu |sed 's/hive-amdgpu-/\t/g'|sort
	echo "${YELLOW}Availible versions of ROCM OpenCL:${NOCOLOR}"
	apt-cache search hive-rocm |sed 's/hive-rocm-/\t/g'|sort
}
_check

# Define the urlcall function
function urlcall {
    local url=$1
    if [[ -z "$url" ]]; then
        echo "${RED}No URL provided!${NOCOLOR}"
        return 1
    fi

    response=$(curl -s "$url")
    if [[ $? -ne 0 ]]; then
        echo "${RED}Failed to fetch URL: $url${NOCOLOR}"
        return 1
    fi

    echo "${CYAN}Response from $url:${NOCOLOR}"
    echo "$response"
}

if [[ -z $rocmVer ]]; then
	case $amdgpuVer in
		20.40)
			rocmVer="3.5"
			;;
		21.40)
			rocmVer="4.5"
			;;
		21.50)
			rocmVer="5.0"
			;;
		22.10)
			rocmVer="5.1"
			;;
		22.20)
			rocmVer="5.2"
			;;
		5.3)
			rocmVer="5.3"
			;;
		5.4)
			rocmVer="5.4"
			;;
		5.5)
			rocmVer="5.5"
			;;
		5.6)
			rocmVer="5.6"
			;;
		5.7)
			rocmVer="5.7"
			;;
                5.8)
			rocmVer="5.8"
			;;
                5.9)
			rocmVer="5.9"
			;;
                6.0)
			rocmVer="6.0"
			;;
                6.1)
			rocmVer="6.1"
			;;
                6.2)
			rocmVer="6.2"
			;;
		*)
			echo "${RED}Error! AMD OpenCL version not specified! ${NOCOLOR}"
			echo
			echo "Examples of usage:"
			echo "	${GREEN}amd-ocl-install 22.20    ${NOCOLOR}	Install full OpenCL from amdgpu 20.40 package (AMDGPU+ROCM)"
			echo "	${GREEN}amd-ocl-install 22.20 5.2${NOCOLOR}	Install amdgpu 22.20 + rocm 5.2"
			echo
			_check_availible
			_check_dist
			exit 1
			;;
	esac
	echo "${CYAN}> Not specified ROCM version, use ${YELLOW}$rocmVer${CYAN} for this version of amdgpu by default${NOCOLOR}"
fi

# Example usage of urlcall function
urlcall "https://api.example.com/some-endpoint"  # Modify this URL as needed

# Uninstall previous libs
echo "${CYAN}> Remove any previously installed OpenCL libs...${NOCOLOR}"
[[ -e /opt/amdgpu/VERSION ]] && _uninstall
# Install new (reinstall) libs
echo "${CYAN}> Install AMDGPU: ${YELLOW}$amdgpuVer${CYAN} and ROCM: ${YELLOW}$rocmVer${CYAN} OpenCL libs...${NOCOLOR}"
apt install -y hive-amdgpu-$amdgpuVer hive-rocm-$rocmVer
# Restart mining && show installed libs
[[ $miner_run -eq 1 ]] && echo "${CYAN}> Restart mining ${NOCOLOR}" && miner start > /dev/null 2>&1
hello redetect
 _check
