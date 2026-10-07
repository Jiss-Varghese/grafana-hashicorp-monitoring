data_dir = "/tmp/nomad"

server {
  enabled          = true
  bootstrap_expect = 1
}

telemetry {
  collection_interval = "1s"
  prometheus_metrics   = true
}

bind_addr = "0.0.0.0"
