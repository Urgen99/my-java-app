
resource "aws_instance" "devops-morning-tf-instance1" {
  ami                    = var.AMIS
  instance_type          = "t2.micro"
  availability_zone      = var.ZONE
  key_name               = "ec2-keypair-urgen"
  vpc_security_group_ids = ["sg-0ce1b40650f0b49fe"]
  tags = {
    Name    = "devops_CI/CD deploy"
    Project = "DevOps"
  }
  provisioner "file" {
    source      = "deployfile.sh"
    destination = "/tmp/deployfile.sh"
  }
  provisioner "remote-exec" {
    inline = [
      "chmod u+x /tmp/deployfile.sh",
      "/tmp/deployfile.sh"
    ]
  }
  connection {
    type        = "ssh"
    user        = var.USER
    private_key = file("/home/vagrant/CICDterrafrom/ec2-keypair-urgen.pem")
    host        = self.public_ip
  }
}