
output "Jenkins_URL" {
   value = "http://${yandex_compute_instance.jenkins[0].network_interface[0].nat_ip_address}:8080"
 }

# # Вывод пароля Jenkins
# output "jenkins_initial_admin_password" {
#   value = data.external.jenkins_password.result.password
# }
# output "bucket_domain_name" {
#   value = "http://${yandex_storage_bucket.vp-bucket.bucket_domain_name}"
# }

# output "connection_string" {
#   description = "Full connection string for the PostgreSQL database"
#   value       = "postgresql://sasha:password@${yandex_compute_instance.postgres.network_interface[0].nat_ip_address}:5432/CoffeeAndTea"
#   sensitive   = true # Скрывает значение при выводе
# }
# output "postgres_public_ip" {
#   value = yandex_compute_instance.postgres.network_interface[0].nat_ip_address
# }
