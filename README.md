# Monitor App

Techstack:
- Python FastAPI app (exposes `/` and `/metrics`)
- Prometheus: Scrapes app metrics)
- Grafana: Visualizes metrics)
- Dockerized for local development
- Optionally deployable on AWS ECS via Terraformand+ Terragrunt

---

## Local Deployment (Docker Compose)

This method allows you to spin up the whole system on your local machine.

### Prerequisites

- Docker & Docker Compose installed
- Ports `5000`, `9090`, and `3000` are free

### Project Structure

```
.
├── app/                    # FastAPI web app (main.py)
├── grafana/config/         # Custom Grafana config (grafana.ini)
├── prometheus/             # Prometheus config (prometheus.yml)
├── docker-compose.yaml     # Main entrypoint for local services
├── Dockerfile              # Builds the FastAPI app container
```

### How to Run Locally

```bash
# Build and start the image
docker compose up --build

### Service Endpoints (Local)

| Service      | URL                         |
|--------------|-----------------------------|
| Web App      | http://localhost:5000       |
| Prometheus   | http://localhost:9090       |
| Grafana      | http://localhost:3000       |

**Grafana Login**:  
Username: `admin`  
Password: `admin`

---

## Cloud Deployment (AWS ECS via Terraform)

> This is an optional production-grade deployment path using AWS.

### 📦 Infrastructure Overview

Provisioned using **Terraform modules** + **Terragrunt wrappers**:

- **ECS Fargate** Cluster for containers
- **ALB (Application Load Balancer)** for routing
- **ECR** for container storage
- **VPC, Subnets, Security Groups**
- **Modularized under `/infrastructure`**

### 📂 Relevant Folder Structure

```
infrastructure/
├── aws/dev/eu-central-1/
│   ├── alb/                # ALB setup (external, HTTP-based)
│   ├── ecr/                # Shared container registry
│   ├── ecs/                # ECS services and cluster
│   ├── sg/                 # Security groups
│   └── vpc/                # VPC and networking
├── modules/                # Reusable Terraform modules
│   ├── terraform-aws-ecs-service
│   ├── terraform-aws-alb
│   └── ...
```

### Service Routing on Cloud

Once deployed, services will be reachable via your ALB:

| Path           | Service      |
|----------------|--------------|
| `/`            | FastAPI app  |
| `/prometheus`  | Prometheus   |
| `/grafana`     | Grafana      |

ALB will be publicly accessible at:

```txt
http://<external-alb-url>.amazonaws.com
```

Testing Metrics

To test Prometheus scraping and Grafana visualizations:

- Visit Prometheus Targets: `http://localhost:9090/targets`
- Add Prometheus in Grafana as a data source (`http://prometheus:9090`)
- Build dashboards using:
  - `request_count`
  - `error_count`

---

## Notes

- The FastAPI app exposes `/metrics` using `prometheus_client`.
- Prometheus is configured to scrape from `web:5000/metrics`.
- Grafana includes a basic `grafana.ini`, but is extensible.

---

## 🧼 Cleanup for local

```bash
docker-compose down -v
docker rmi monitor-app
```