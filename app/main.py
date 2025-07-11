from fastapi import FastAPI, Request
from prometheus_client import Counter, generate_latest, CONTENT_TYPE_LATEST
from fastapi.responses import Response

app = FastAPI()

# sample prometheus metrics:
REQUEST_COUNT = Counter(
    'http_requests_total',
    'Total HTTP Requests',
    ['method', 'endpoint', 'status']
)
ERROR_COUNT = Counter(
    'http_errors_total',
    'Total HTTP Errors',
    ['method', 'endpoint', 'status']
)

@app.get("/")
async def root():
    REQUEST_COUNT.labels('GET', '/', '200').inc()
    return {"message": "Hi, this is the Monitor App v1.0"}

@app.route('/error')
def simulate_error():
    REQUEST_COUNT.labels('GET', '/simulate_error', '500').inc()
    ERROR_COUNT.labels('GET', '/simulate_error', '500').inc()
    return Response(status_code=500)
