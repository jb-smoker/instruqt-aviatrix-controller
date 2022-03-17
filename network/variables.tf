# variable "ace_ctrl_password" {}
# variable "ace_student_password" {}
# variable "controller_public_ip" {}
# variable "copilot_public_ip" {}

variable "azure_subscription_id" {}
variable "azure_directory_id" {}
variable "azure_application_id" {}
variable "azure_application_key" {}

variable "avtx_key_name" { default = "avtx_key" }

variable "aws_region-2" {
  default = "us-east-2"
}

variable "aws_region-1" {
  default = "us-east-1"
}


variable "aws_ami_lab3" {
  description = "amazon linux"
  default     = "ami-0603cbe34fd08cb81"
}

variable "aws_copilot_lab3" {
  description = "copilot"
  default     = "ami-0a05466b9530dfb19"
}

variable "aws_ami_lab5" {
  description = "amazon linux"
  default     = "ami-0c94855ba95c71c99"
}

variable "aws_ami_csr_lab5" {
  description = "cisco csr image"
  default     = "ami-0eb9c4f673471b033"
}

variable "az_region" {
  default = "West US"
}

variable "gcp_region" {
  default = "us-central1"
}

locals {
  # separate user_data to label unique server name command prompt
  user_data_east1_spoke1_test1 = <<EOF
#!/bin/bash
sudo sed -i 's/PasswordAuthentication no/PasswordAuthentication yes/g' /etc/ssh/sshd_config
sudo echo 'ec2-user:${var.aviatrix_password}' | sudo /usr/sbin/chpasswd
sudo adduser student
sudo echo 'student:${var.aviatrix_password}' | sudo /usr/sbin/chpasswd
sudo sed --in-place 's/^#\s*\(%wheel\s\+ALL=(ALL)\s\+NOPASSWD:\s\+ALL\)/\1/' /etc/sudoers
sudo usermod -aG wheel student
sudo service sshd restart
echo "#!/bin/sh
prompt_command () {
    export PS1='\[\e[1;32m\][\u@aws-us-east1-spoke1-test1 \W]\$\[\e[0m\] '
}
PROMPT_COMMAND=prompt_command
" | sudo tee /etc/profile.d/shell-color.sh
sudo yum update -y

EOF
  user_data_east1_spoke1_test2 = <<EOF
#!/bin/bash
sudo sed -i 's/PasswordAuthentication no/PasswordAuthentication yes/g' /etc/ssh/sshd_config
sudo echo 'ec2-user:${var.aviatrix_password}' | sudo /usr/sbin/chpasswd
sudo adduser student
sudo echo 'student:${var.aviatrix_password}' | sudo /usr/sbin/chpasswd
sudo sed --in-place 's/^#\s*\(%wheel\s\+ALL=(ALL)\s\+NOPASSWD:\s\+ALL\)/\1/' /etc/sudoers
sudo usermod -aG wheel student
sudo service sshd restart
echo "#!/bin/sh
prompt_command () {
    export PS1='\[\e[1;32m\][\u@aws-us-east1-spoke1-test2 \W]\$\[\e[0m\] '
}
PROMPT_COMMAND=prompt_command
" | sudo tee /etc/profile.d/shell-color.sh
sudo yum update -y

EOF
  user_data_east2_spoke1_test1 = <<EOF
#!/bin/bash
sudo sed -i 's/PasswordAuthentication no/PasswordAuthentication yes/g' /etc/ssh/sshd_config
sudo echo 'ec2-user:${var.aviatrix_password}' | sudo /usr/sbin/chpasswd
sudo adduser student
sudo echo 'student:${var.aviatrix_password}' | sudo /usr/sbin/chpasswd
sudo sed --in-place 's/^#\s*\(%wheel\s\+ALL=(ALL)\s\+NOPASSWD:\s\+ALL\)/\1/' /etc/sudoers
sudo usermod -aG wheel student
sudo service sshd restart
echo "#!/bin/sh
prompt_command () {
    export PS1='\[\e[1;32m\][\u@aws-us-east2-spoke1-test1 \W]\$\[\e[0m\] '
}
PROMPT_COMMAND=prompt_command
" | sudo tee /etc/profile.d/shell-color.sh
sudo yum update -y

EOF
}
