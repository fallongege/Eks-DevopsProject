resource "aws_key_pair" "public-key" {
  key_name   = "jenkins-server-key"
  public_key = tls_private_key.private-key.public_key_openssh
}
resource "tls_private_key" "private-key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}
resource "local_file" "tf-efs-demo-key" {
  content         = tls_private_key.private-key.private_key_pem
  filename        = "${path.module}/jenkins-key.pem"
  file_permission = "0600"
}

output "key_name" {
  value = aws_key_pair.public-key.key_name
}

output "key_fingerprint" {
  value = aws_key_pair.public-key.fingerprint
}