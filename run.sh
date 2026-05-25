#!/bin/bash
# Build and launch Water Reminder in the background
cd "$(dirname "$0")"
swift build -c release 2>&1 | tail -3
echo "Launching Water Reminder…"
.build/release/WaterReminder &
echo "Running as PID $! - check the drop icon in your menu bar"
echo "To stop: pkill WaterReminder"
