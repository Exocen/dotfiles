#!/usr/bin/env bash
curl -X PUT --fail --silent --show-error http://localhost:8000/v1/openvpn/status -H "Content-Type: application/json" -d '{"status":"stopped"}'
sleep 5s
curl -X PUT --fail --silent --show-error http://localhost:8000/v1/openvpn/status -H "Content-Type: application/json" -d '{"status":"running"}'
echo "Ip switch initiated"
sleep 60s