from fastapi import FastAPI, Request
from prometheus_client import Counter, generate_latest, CONTENT_TYPE_LATEST
from fastapi.responses import Response

app = FastAPI()

# sample prometheus metrics:
REQUEST_COUNT = Counter("request_count", "Total number of requests")
ERROR_COUNT = Counter("error_count", "Number of error responses")

@app.get("/")
async def root():
    REQUEST_COUNT.inc()
    return {"message": "Hi, this is the Monitor App v1.0"}