# DEFINE ALL YOUR VARIABLES HERE

instance_type = "t2.large" # Change as per your requirement
ami           = "ami-020cba7c55df1f615" # Ubuntu 24.04
#key_name      = "mac2-keypair"          # Replace with your key-name without .pem extension
volume_size   = 30
region_name   = "us-east-1"
server_name   = "JENKINS-SERVER"

# Note: 
# a. First create a pem-key manually from the AWS console
# b. Copy it in the same directory as your terraform code
