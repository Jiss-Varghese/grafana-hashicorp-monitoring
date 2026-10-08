data_dir = "/tmp/nomad-server2"

name = "nomad-server-2"

bind_addr = "0.0.0.0"



server {
  enabled          = true
  bootstrap_expect = 3

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