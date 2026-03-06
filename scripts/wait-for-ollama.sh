#!/bin/bash
set -e

echo "⏳ Aguardando Ollama iniciar..."

until curl -sf http://ollama:11434/api/tags > /dev/null 2>&1; do
    sleep 2
done

echo "✅ Ollama pronto!"
