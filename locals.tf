locals {
  # v2 ingress enum -> v1 run.googleapis.com/ingress annotation value
  legacy_ingress = {
    INGRESS_TRAFFIC_ALL                    = "all"
    INGRESS_TRAFFIC_INTERNAL_ONLY          = "internal"
    INGRESS_TRAFFIC_INTERNAL_LOAD_BALANCER = "internal-and-cloud-load-balancing"
  }
}
