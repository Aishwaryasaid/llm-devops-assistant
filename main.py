from fastapi import FastAPI
from pydantic import BaseModel
import requests
import os

OLLAMA_HOST = os.getenv("OLLAMA_HOST", "http://localhost:11434")
app = FastAPI()

messages = [
    {"role": "system", "content": "You are a DevOps expert. Help users troubleshoot infrastructure issues, explain DevOps concepts, and advise on best practices for Kubernetes, AWS, and CI/CD pipelines."}
]


class ChatRequest(BaseModel):
    message: str


@app.post("/chat")
def chat_create(request: ChatRequest):
    messages.append({"role": "user", "content": request.message})

    try:
        response = requests.post(
            f"{OLLAMA_HOST}/api/chat",
            json={
                "model": "llama3.2",
                "messages": messages,
                "stream": False
            }
        )
        reply = response.json()["message"]["content"]
        messages.append({"role": "assistant", "content": reply})
        return {"reply": reply}
    except requests.exceptions.ConnectionError:
        return {"error": "Ollama is not reachable. Is it running?"}


@app.get("/health")
def health_app():
    try:
        response = requests.get(f"{OLLAMA_HOST}")
        if response.status_code == 200:
            return {"status": "ok", "ollama": "running"}
    except requests.exceptions.ConnectionError:
        return {"status": "ok", "ollama": "not running"}


@app.get("/models")
def ollama_models():
    try:
        response = requests.get(f"{OLLAMA_HOST}/api/tags")
        return response.json()["models"]
    except requests.exceptions.ConnectionError:
        return {"error": "Ollama is not reachable"}