#!/usr/bin/env bash
curl -X PUT --fail --silent --show-error http://localhost:8000/v1/openvpn/status -H "Content-Type: application/json" -d '{"status":"stopped"}'
curl -X PUT --fail --silent --show-error http://localhost:8000/v1/openvpn/status -H "Content-Type: application/json" -d '{"status":"running"}'