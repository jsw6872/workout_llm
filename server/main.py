from typing import Union
from typing import *
from fastapi import FastAPI
from starlette.middleware.cors import CORSMiddleware

from api import whisper

app = FastAPI()

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

app.include_router(whisper.router)

@app.get("/ping")
def ping():
    return {"message" : "pong"}