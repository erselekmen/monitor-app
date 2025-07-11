from fastapi import FastAPI, Request
from prometheus_client import Counter, generate_latest, CONTENT_TYPE_LATEST
from fastapi.responses import Response

app = FastAPI()

@app.get("/")
async def root():
    return {"message": "Hi, this is the Monitor App v1.0"}