output "az_tls_private_key" {
  value     = tls_private_key.sdm_ssh.public_key_openssh
  sensitive = true
}