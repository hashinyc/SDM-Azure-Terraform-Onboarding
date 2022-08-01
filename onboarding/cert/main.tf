resource "tls_private_key" "sdm_ssh" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "local_file" "sdm_key" {
  content         = tls_private_key.sdm_ssh.private_key_pem
  filename        = "az_sdm_priv_key.pem"
  file_permission = "0600"
}

resource "local_file" "pub_key" {
  content         = tls_private_key.sdm_ssh.public_key_openssh
  filename        = "az_sdm_pub_key.pub"
  file_permission = "0600"
}