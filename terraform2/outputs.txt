output "cluster_nat_IP" {
  value = yandex_compute_instance.cluster.*.network_interface.0.nat_ip_address
}

# output "Jenkins_URL" {
#    value = "http://${yandex_compute_instance.jenkins[0].network_interface[0].nat_ip_address}:8080"
#  }
# output "bucket_domain_name" {
#   value = "http://${yandex_storage_bucket.vp-bucket.bucket_domain_name}"
# }

# output "connection_string" {
#   description = "Full connection string for the PostgreSQL database"
#   value       = "postgresql://sasha:password@${yandex_compute_instance.postgres.network_interface[0].nat_ip_address}:5432/CoffeeAndTea"
#   sensitive   = true # Скрывает значение при выводе
# }
output "postgres_public_ip" {
  value = yandex_compute_instance.postgres.network_interface[0].nat_ip_address
}
