#!/bin/bash

echo "Aguardando Ollama iniciar..."

until curl -s http://ollama:11434/api/tags > /dev/null; do
  sleep 2
done

echo "Ollama pronto!"
