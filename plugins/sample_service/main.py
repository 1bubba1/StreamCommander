#!/usr/bin/env python3
"""
Sample Streaming Service Plugin

Communicates with the engine via stdin/stdout JSON lines protocol.
All logging goes to stderr.
"""
import sys
import json
import logging

# Log to stderr only — stdout is reserved for the protocol
logging.basicConfig(
    stream=sys.stderr,
    level=logging.INFO,
    format="%(asctime)s [%(levelname)s] %(message)s"
)
logger = logging.getLogger("sample_service")


def handle_command(command: str, data: dict) -> dict:
    if command == "fetch_content":
        return {
            "status": "success",
            "items": [
                {"id": "1", "title": "Sample Content 1", "type": "video"},
                {"id": "2", "title": "Sample Content 2", "type": "audio"}
            ]
        }
    elif command == "sync_library":
        return {"status": "success", "synced_items": 42}
    elif command == "search":
        query = data.get("query", "")
        return {
            "status": "success",
            "results": [
                {"id": "1", "title": f"Result for: {query}", "match_score": 0.95}
            ]
        }
    else:
        return {"status": "error", "message": f"Unknown command: {command}"}


def main():
    # Signal readiness to the engine
    sys.stdout.write(json.dumps({"status": "ready"}) + "\n")
    sys.stdout.flush()
    logger.info("Sample plugin ready")

    # Process commands from stdin
    for line in sys.stdin:
        line = line.strip()
        if not line:
            continue

        try:
            request = json.loads(line)
            request_id = request.get("id")
            command = request.get("command", "")
            data = request.get("data", {})

            logger.info("Received command: %s", command)
            result = handle_command(command, data or {})

            # Echo back the request ID
            result["id"] = request_id

            sys.stdout.write(json.dumps(result) + "\n")
            sys.stdout.flush()
        except Exception as e:
            logger.error("Error processing request: %s", e)
            error_resp = {"id": None, "status": "error", "message": str(e)}
            try:
                error_resp["id"] = json.loads(line).get("id")
            except Exception:
                pass
            sys.stdout.write(json.dumps(error_resp) + "\n")
            sys.stdout.flush()


if __name__ == "__main__":
    main()

