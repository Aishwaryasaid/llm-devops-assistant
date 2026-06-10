# 🤖 LLM DevOps Assistant

A locally-running DevOps Q&A assistant powered by a local LLM (via Ollama), wrapped in a FastAPI API and fully containerized with Docker Compose.

Ask it anything — *why is my pod crashlooping, explain blue-green deployments, how do I debug a 5xx in ALB* — and get clear, expert answers without sending data to any external API.

---
ß
## Architecture

```
User → FastAPI (/chat) → Ollama (llama3.2) → Response
```

Both services run as Docker containers and communicate over an internal Docker network. Ollama model data is persisted via a named volume.

---

## Features

- 💬 Multi-turn conversation — follows up on context within a session
- 🏥 `/health` endpoint — checks if Ollama is reachable
- 📋 `/models` endpoint — lists available Ollama models
- 🐳 Fully containerized — runs with a single `docker compose up`
- 🔒 No external LLM API — everything runs locally

---

## Tech Stack

| Layer | Technology |
|---|---|
| API | FastAPI (Python 3.12) |
| LLM Runtime | Ollama |
| Model | llama3.2 |
| Containerization | Docker + Docker Compose |
| Base Image | python:3.12-alpine |
| CI/CD | GitHub Actions |
| Registry | DockerHub (`ash392/llm-devops-assistant`) |

---

## Getting Started

### Prerequisites

- [Docker](https://docs.docker.com/get-docker/)
- [Docker Compose](https://docs.docker.com/compose/)

### Run locally

```bash
# Clone the repo
git clone https://github.com/Aishwaryasaid/llm-devops-assistant.git
cd llm-devops-assistant

# Start both services
docker compose up --build
```

The API will be available at `http://localhost:8000`.

> **Note:** On first run, Ollama will pull the `llama3.2` model (~2GB). This only happens once — the model is cached in a Docker volume.

### Pull from DockerHub

```bash
docker pull ash392/llm-devops-assistant
```

---

## API Reference

### `POST /chat`

Send a message to the DevOps assistant.

**Request**
```json
{
  "message": "Why is my pod stuck in CrashLoopBackOff?"
}
```

**Response**
```json
{
  "reply": "CrashLoopBackOff means your container is starting, crashing, and Kubernetes keeps restarting it..."
}
```

---

### `GET /health`

Check if the API and Ollama are running.

**Response**
```json
{
  "status": "ok",
  "ollama": "running"
}
```

---

### `GET /models`

List available Ollama models.

**Response**
```json
[
  { "name": "llama3.2", ... }
]
```

---

## Project Structure

```
llm-devops-assistant/
├── main.py               # FastAPI app
├── Dockerfile            # App container
├── docker-compose.yml    # Orchestrates app + Ollama
├── requirements.txt      # Python dependencies
└── .github/
    └── workflows/
        └── ci.yml        # GitHub Actions CI/CD pipeline
```

---

## CI/CD

Every push to `main`:
1. Lints and validates the codebase
2. Builds the Docker image
3. Pushes to DockerHub as `ash392/llm-devops-assistant:latest`

---

## Infrastructure (v2)

The `terraform/` directory provisions the AWS infrastructure to run this app in the cloud:

- VPC with public subnet
- EC2 instance with Docker + Docker Compose
- Security group (ports 22, 8000)
- Auto-pulls the DockerHub image on launch via user data script

```bash
cd terraform
terraform init
terraform apply
```

---

## Known Limitations

- Conversation history is stored in memory — restarting the app resets context
- Single-user only — no session isolation between concurrent users
- No authentication on API endpoints

These are intentional trade-offs for v1 simplicity and are candidates for future improvement.

---

## Roadmap

- [ ] GitHub Actions CI/CD pipeline
- [ ] Terraform EC2 deployment (v2)
- [ ] Session-based conversation history
- [ ] Migrate to EKS (v3)

---

## Author

**Aishwarya** — Cloud & DevOps Engineer  
[GitHub](https://github.com/Aishwaryasaid) · [LinkedIn](https://linkedin.com/in/your-profile)