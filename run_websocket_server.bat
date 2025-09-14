@echo off
REM Batch script to navigate to project directory and run websocket_server.js

cd /d "e:\Pang Capstone\Flutter Apps\flutter_application_1"
if errorlevel 1 (
  echo Failed to change directory. Please check the path.
  pause
  exit /b 1
)

echo Changed directory to:
cd

echo Starting WebSocket server...
node websocket_server.js

if errorlevel 1 (
  echo Failed to start WebSocket server. Please check for errors above.
  pause
  exit /b 1
)
