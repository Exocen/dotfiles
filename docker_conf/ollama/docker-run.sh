#!/bin/bash

if [ "$(id -u)" -ne 0 ]; then
	echo "Must be run as root"
	exit 1
fi

DOCKER_PATH="/docker-data/ollama"

cd "$(dirname "$(readlink -f "$0")")" || exit 1
mkdir -p $DOCKER_PATH

docker run -d --name ollama --log-driver=journald --log-opt tag="{{.Name}}" --rm \
	--privileged \
	--device /dev/kfd --device /dev/dri -p 11434:11434 -v "$DOCKER_PATH":/root/.ollama \
	-e HSA_OVERRIDE_GFX_VERSION=10.3.0 -e OLLAMA_FLASH_ATTENTION=1 \
	-e OLLAMA_KV_CACHE_TYPE=q8_0 -e OLLAMA_KEEP_ALIVE=24h \
	-e OLLAMA_CONTEXT_LENGTH=16384 \
	ollama/ollama:rocm && echo "ollama started."

docker exec -it ollama ollama list | grep 'qwen3' &>/dev/null || docker exec -it ollama ollama pull qwen3:8b
