GRAFANA HASHICORP MONITORING

Create a standard Grafana dashboard for monitoring node metrics and logs, with monitoring dashboards for Nomad, Consul, and Vault, including alerting and reusable documentation.

Final architecture

```text

                         ┌─────────────────────┐
                         │       Grafana       │
                         │                     │
                         │ Node Dashboard      │
                         │ Nomad Dashboard     │
                         │ Consul Dashboard    │
                         │ Vault Dashboard     │
                         └──────────┬──────────┘
                                    │
                       ┌────────────┴────────────┐
                       │                         │
                 Prometheus                   Loki
                 Metrics DB                  Logs DB
                       │                         │
          ┌────────────┼────────────┐            │
          │            │            │            │
          ▼            ▼            ▼            ▼
    Node Exporter    Nomad       Consul       Alloy
                     metrics      metrics      logs
          │            │            │            │
          ▼            ▼            ▼            ▼
       Node         Nomad        Consul      Host/service
      metrics       cluster      cluster        logs
                                     
                         ┌─────────────┐
                         │    Vault    │
                         │  metrics   │
                         └──────┬──────┘
                                │
                                ▼
                           Prometheus


```

Project phases<br>
PHASE 1   Project preparation<br>
PHASE 2   Monitoring stack<br>
PHASE 3   Subtask 1 – Research metrics<br>
PHASE 4   Nomad setup<br>
PHASE 5   Subtask 2 – Nomad dashboard<br>
PHASE 6   Subtask 3 – Alerting<br>
PHASE 7   Consul setup<br>
PHASE 8   Subtask 4 – Consul dashboard<br>
PHASE 9   Vault setup<br>
PHASE 10  Subtask 5 – Vault dashboard<br>
PHASE 11  Node metrics dashboard<br>
PHASE 12  Loki + Alloy logs<br>
PHASE 13  Reusable dashboard variables<br>
PHASE 14  Dashboard provisioning<br>
PHASE 15  Testing<br>
PHASE 16  Documentation<br>


PHASE 1 — Project Setup
Step 1 — Create project directory

cd ~/Documents
mkdir grafana-hashicorp-monitoring
cd grafana-hashicorp-monitoring

Step 2 — Create project structure

mkdir -p prometheus
mkdir -p grafana/provisioning/datasources
mkdir -p grafana/provisioning/dashboards
mkdir -p grafana/dashboards
mkdir -p loki
mkdir -p alloy
mkdir -p nomad
mkdir -p consul
mkdir -p vault
mkdir -p alertmanager
mkdir -p docs

find . -maxdepth 3 -type d

Step 3 — Create initial files

touch docker-compose.yml
touch prometheus/prometheus.yml
touch prometheus/alerts.yml
touch alertmanager/alertmanager.yml
touch loki/loki.yml
touch alloy/config.alloy
touch grafana/provisioning/datasources/datasources.yml
touch grafana/provisioning/dashboards/dashboards.yml
touch docs/README.md
touch docs/metrics-research.md

PHASE 2 — Monitoring stack
```text
| Component     | Purpose        |
| ------------- | -------------- |
| Grafana       | Visualization  |
| Prometheus    | Metrics        |
| Node Exporter | Host metrics   |
| Loki          | Logs           |
| Alloy         | Log collection |
| Alertmanager  | Alert routing  |
```

Step 4 — Create Docker Compose

Open:

docker-compose.yml
```text
services:

  prometheus:
    image: prom/prometheus:v3.5.0
    container_name: grafana-hashicorp-prometheus
    ports:
      - "9091:9090"
    volumes:
      - ./prometheus/prometheus.yml:/etc/prometheus/prometheus.yml:ro
      - ./prometheus/alerts.yml:/etc/prometheus/alerts.yml:ro
    command:
      - "--config.file=/etc/prometheus/prometheus.yml"
    restart: unless-stopped
  consul:
    image: hashicorp/consul:latest
    container_name: grafana-hashicorp-consul
    ports:
      - "8700:8500"
    volumes:
      - ./consul/consul.hcl:/consul/config/consul.hcl:ro  
    command:
      - "agent"
      - "-server"
      - "-bootstrap-expect=1"
      - "-ui"
      - "-client=0.0.0.0"
      - "-bind=0.0.0.0"
      - "-log-level=INFO"
    restart: unless-stopped
  vault:
    image: hashicorp/vault:latest
    container_name: grafana-hashicorp-vault
    ports:
      - "8201:8200"
    cap_add:
      - IPC_LOCK
    environment:
      VAULT_DEV_ROOT_TOKEN_ID: "root"
      VAULT_DEV_LISTEN_ADDRESS: "0.0.0.0:8200"
    command:
      - "server"
      - "-dev"
      - "-dev-root-token-id=root"
      - "-dev-listen-address=0.0.0.0:8200"  
    restart: unless-stopped


  node-exporter:
    image: prom/node-exporter:v1.9.1
    container_name: grafana-hashicorp-node-exporter
    ports:
      - "9101:9100"
    restart: unless-stopped

  loki:
    image: grafana/loki:3.5.0
    container_name: grafana-hashicorp-loki
    ports:
      - "3101:3100"
    volumes:
      - ./loki/loki.yml:/etc/loki/config.yml:ro
    command:
      - "-config.file=/etc/loki/config.yml"
    restart: unless-stopped

  alloy:
    image: grafana/alloy:v1.10.0
    container_name: grafana-hashicorp-alloy
    ports:
      - "12346:12345"
    volumes:
      - ./alloy/config.alloy:/etc/alloy/config.alloy:ro
      - /var/log:/var/log:ro
    command:
      - "run"
      - "--server.http.listen-addr=0.0.0.0:12345"
      - "/etc/alloy/config.alloy"
    restart: unless-stopped

  grafana:
    image: grafana/grafana:12.1.1
    container_name: grafana-hashicorp-grafana
    ports:
      - "3001:3000"
    volumes:
      - grafana-data:/var/lib/grafana
      - ./grafana/provisioning:/etc/grafana/provisioning
      - ./grafana/dashboards:/var/lib/grafana/dashboards
    restart: unless-stopped

  alertmanager:
    image: prom/alertmanager:v0.28.1
    container_name: grafana-hashicorp-alertmanager
    ports:
      - "9093:9093"
    volumes:
      - ./alertmanager/alertmanager.yml:/etc/alertmanager/alertmanager.yml:ro
    command:
      - "--config.file=/etc/alertmanager/alertmanager.yml"
    restart: unless-stopped

  nomad:
    image: hashicorp/nomad:latest
    container_name: grafana-hashicorp-nomad
    ports:
      - "4646:4646"
      - "4647:4647"
      - "4648:4648"
    volumes:
      - ./nomad/nomad.hcl:/etc/nomad.d/nomad.hcl:ro
    command:
      - "agent"
      - "-config=/etc/nomad.d/nomad.hcl"
      - "-server"
      - "-bootstrap-expect=1"
      - "-bind=0.0.0.0"
      - "-log-level=INFO"
    restart: unless-stopped

volumes:
  grafana-data:
  vault-data:

  ```

  Step 5 — Prometheus configuration

Open:

prometheus/prometheus.yml
```text
global:
  scrape_interval: 15s
  evaluation_interval: 15s

rule_files:
  - /etc/prometheus/alerts.yml

scrape_configs:

  - job_name: prometheus
    static_configs:
      - targets:
          - prometheus:9090
        labels:
          environment: lab
          service: prometheus

  - job_name: node-exporter
    static_configs:
      - targets:
          - node-exporter:9100
        labels:
          environment: lab
          service: node
          node: local-node

  - job_name: nomad
    metrics_path: /v1/metrics
    params:
      format:
        - prometheus
    static_configs:
      - targets:
          - nomad:4646
        labels:
          environment: lab
          service: nomad

  - job_name: consul
    metrics_path: /v1/agent/metrics
    params:
      format:
        - prometheus
    static_configs:
      - targets:
          - consul:8500
        labels:
          environment: lab
          service: consul

  - job_name: vault
    metrics_path: /v1/sys/metrics
    params:
      format:
        - prometheus
    static_configs:
      - targets:
          - vault:8200
        labels:
          environment: lab
          service: vault


```

Step 6 — Prometheus alert configuration

prometheus/alerts.yml

Step 7 — Alertmanager

alertmanager/alertmanager.yml

Step 8 — Loki configuration

loki/loki.yml

Step 9 — Alloy configuration
alloy/config.alloy


Step 10 — Grafana datasource configuration
grafana/provisioning/datasources/datasources.yml

Step 11 — Grafana dashboard provisioning

grafana/provisioning/dashboards/dashboards.yml

Step 12 — Start the monitoring stack

docker compose up -d
docker compose ps

Step 13 — Check container logs

docker compose logs --tail=50 prometheus
docker compose logs --tail=50 grafana

docker compose logs --tail=50 loki

docker compose logs --tail=50 alloy

docker compose logs --tail=50 alertmanager
Step 14 — Open Grafana

Open:

http://localhost:3001

Login:

Username: admin
Password: admin

Step 15 — Check Prometheus

Open:

http://localhost:9091

Go to:

Status
→ Targets

PHASE 3 — SUBTASK 1
Research Prometheus Metrics

Step 16 — Research Nomad metrics

curl "http://localhost:4646/v1/metrics?format=prometheus"

curl "http://localhost:4646/v1/metrics?format=prometheus" \
  > docs/nomad-metrics.txt

  grep -E "^# HELP|^nomad_" docs/nomad-metrics.txt | head -100

  Step 17 — Research Consul metrics

  curl "http://localhost:8500/v1/agent/metrics?format=prometheus"

  curl "http://localhost:8500/v1/agent/metrics?format=prometheus" \
  > docs/consul-metrics.txt

