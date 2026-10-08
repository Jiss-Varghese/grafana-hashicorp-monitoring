data_dir = "/tmp/nomad-client2"

name = "nomad-client-2"

bind_addr = "0.0.0.0"

client {
  enabled = true
  cpu_total_compute = 16000

  server_join {
    retry_join = [
      "nomad-server-1",
      "nomad-server-2",
      "nomad-server-3"
    ]

    retry_interval = "10s"
  }
}

telemetry {
  collection_interval = "1s"
  prometheus_metrics   = true
}
