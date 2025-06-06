#!/bin/bash

# Paths
CONF_DIR="User_Equipment/configs"
MODULE_CONF="MyMod.conf"

# Count ue{i}.conf files (e.g., ue1.conf, ue2.conf, etc.)
UE_COUNT=$(find "$CONF_DIR" -type f -regex '.*/ue[0-9]+\.conf' | wc -l)

# Extract NUM_UES from MyMod.conf
NUM_UES=$(grep -oP 'NUM_UES\s*=\s*\K[0-9]+' "$MODULE_CONF")

echo "Detected UE config files : $UE_COUNT"
echo "Expected number of UEs    : $NUM_UES"

# Compare values
if [[ "$UE_COUNT" -eq "$NUM_UES" ]]; then
  echo "UE count matches NUM_UES in MyMod.conf CONTINUE RUNNING AS USUAL"
else
  echo "Mismatch: $UE_COUNT UE files found, but NUM_UES=$NUM_UES in config"
  ./User_Equipment/generate_configurations.sh
  UE_COUNT=$(find "$CONF_DIR" -type f -regex '.*/ue[0-9]+\.conf' | wc -l)
  NUM_UES=$(grep -oP 'NUM_UES\s*=\s*\K[0-9]+' "$MODULE_CONF")
  echo "Detected UE config files : $UE_COUNT"
  echo "Expected number of UEs    : $NUM_UES"
  if [[ "$UE_COUNT" -eq "$NUM_UES" ]]; then
    echo "UE count matches NUM_UES in MyMod.conf CONTINUE RUNNING AS USUAL"
  else
    exit 1
  fi
fi



echo 
echo "Running $NUM_UES UEs"
echo "y:Yes, n:No, a:All"
read -p "Your choice (y/a/n): " choice

if [[ "$choice" =~ ^[Aa]$ ]]; then
  ./generate_configurations.sh
  ./run_with_grafana_dashboard.sh

elif [[ "$choice" =~ ^[Yy]$ ]]; then
  ./generate_configurations.sh
  read -p "Your choice (y/n): " choice1
  if [[ "$choice1" =~ ^[Yy]$ ]]; then
    ./run_with_grafana_dashboard.sh
  elif [[ "$choice1" =~ ^[Nn]$ ]]; then
    echo "No action taken. Exiting."
  fi
elif [[ "$choice" =~ ^[Nn]$ ]]; then
  echo "No action taken. Exiting."

else
  echo "Invalid option. Please run again and choose y, a, or n."
  exit 1
fi