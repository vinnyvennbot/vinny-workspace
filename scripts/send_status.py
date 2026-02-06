#!/usr/bin/env python3
"""
Local Status Tracking - No external dependencies
Writes status to filesystem for monitoring and logging
"""

import sys
import os
import json
from datetime import datetime
from pathlib import Path

def send_status(message, status_type="progress", task_id="default", details=None):
    """
    Send status update to local filesystem
    
    Args:
        message: Status message to log
        status_type: progress|success|error|warning
        task_id: Identifier for the task
        details: Optional additional details
    """
    
    # Create logs directory if it doesn't exist
    logs_dir = Path("logs")
    logs_dir.mkdir(exist_ok=True)
    
    # Status symbols
    symbols = {
        "progress": "🔄",
        "success": "✅", 
        "error": "❌",
        "warning": "⚠️"
    }
    
    symbol = symbols.get(status_type, "ℹ️")
    timestamp = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
    
    # Create status entry
    status_entry = {
        "timestamp": timestamp,
        "type": status_type,
        "task_id": task_id,
        "message": message,
        "details": details
    }
    
    # Write to current status file (for monitoring)
    status_file = logs_dir / "current_status.txt"
    with open(status_file, "w") as f:
        f.write(f"{symbol} {message}")
    
    # Append to task log (for history)
    task_log = logs_dir / f"task_{task_id}.log"
    with open(task_log, "a") as f:
        f.write(f"[{timestamp}] {symbol} {message}\n")
        if details:
            f.write(f"    Details: {details}\n")
    
    # Write JSON log (for programmatic access)
    json_log = logs_dir / "status_history.jsonl"
    with open(json_log, "a") as f:
        f.write(json.dumps(status_entry) + "\n")
    
    # Print to console
    print(f"{symbol} [{task_id}] {message}")
    if details:
        print(f"    {details}")

if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Usage: python scripts/send_status.py <message> [type] [task_id] [details]")
        print("Types: progress, success, error, warning")
        sys.exit(1)
    
    message = sys.argv[1]
    status_type = sys.argv[2] if len(sys.argv) > 2 else "progress"
    task_id = sys.argv[3] if len(sys.argv) > 3 else "default"  
    details = sys.argv[4] if len(sys.argv) > 4 else None
    
    send_status(message, status_type, task_id, details)