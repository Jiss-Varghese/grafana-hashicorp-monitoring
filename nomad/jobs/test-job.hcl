job "test-job" {
  datacenters = ["dc1"]

  group "test" {
    count = 2

    task "server" {
      driver = "docker"

      config {
        image = "nginx:alpine"
      }

      resources {
        cpu    = 100
        memory = 128
      }
    }
  }
}