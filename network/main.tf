variable "aviatrix_controller_ip" {}
variable "aviatrix_username" {}
variable "aviatrix_password" {}
# variable "gcp_project_id" {}
# variable "gcp_credentials" {}

provider "aviatrix" {
  controller_ip = var.aviatrix_controller_ip
  username      = var.aviatrix_username
  password      = var.aviatrix_password
}

# --------------------------------------------

# aviatrix student user
resource "aviatrix_account_user" "student" {
  username = "student"
  email    = "ace.lab@aviatrix.com"
  password = var.aviatrix_password
}

resource "aviatrix_rbac_group_user_attachment" "student" {
  group_name = "admin"
  user_name  = aviatrix_account_user.student.username
}

# resource "aviatrix_remote_syslog" "copilot" {
#   name     = "copilot"
#   server   = var.copilot_public_ip
#   port     = 5000
#   protocol = "UDP"
# }

# resource "aviatrix_netflow_agent" "copilot" {
#   server_ip = var.copilot_public_ip
#   port      = 31283
#   version   = "9"
# }

# resource "aviatrix_copilot_association" "copilot" {
#   copilot_address = "cplt.${terraform.workspace}.aviatrixlab.com"
# }

resource "aviatrix_vpc" "aws-us-east2-transit" {
  cloud_type           = 1
  account_name         = "aws-account"
  region               = var.aws_region-2
  name                 = "aws-us-east2-transit"
  cidr                 = "10.0.10.0/23"
  aviatrix_transit_vpc = true
  aviatrix_firenet_vpc = false
}

resource "aviatrix_vpc" "aws-us-east2-spoke1" {
  cloud_type           = 1
  account_name         = "aws-account"
  aviatrix_transit_vpc = false
  aviatrix_firenet_vpc = false
  name                 = "aws-us-east2-spoke1"
  region               = "us-east-2"
  cidr                 = "10.0.1.0/24"
  subnet_size          = "27"
  num_of_subnet_pairs  = "3"
}

module "transit_azure_us_west" {
  source  = "terraform-aviatrix-modules/mc-transit/aviatrix"
  version = "1.1.0"

  account                = "azure-account"
  az_support             = false
  cidr                   = "192.168.10.0/23"
  cloud                  = "Azure"
  connected_transit      = true // transit firenet needs to enable connected transit
  enable_transit_firenet = true
  ha_gw                  = true
  instance_size          = "Standard_B2s"
  name                   = "azure-us-west-transit-agw"
  region                 = var.az_region
}

# module "transit_gcp_us_central1" {
#   source  = "terraform-aviatrix-modules/mc-transit/aviatrix"
#   version = "1.1.0"

#   account       = "gcp-account"
#   cidr          = "172.16.10.0/23"
#   cloud         = "GCP"
#   ha_gw         = true
#   instance_size = "n1-standard-1"
#   name          = "gcp-us-central1-transit-agw"
#   region        = var.gcp_region
#   single_az_ha  = false
# }

module "transit_aws_us_east1" {
  source  = "terraform-aviatrix-modules/mc-transit/aviatrix"
  version = "1.1.0"

  account       = "aws-account"
  cidr          = "10.0.20.0/23"
  cloud         = "AWS"
  ha_gw         = true
  insane_mode   = true
  instance_size = "c5n.large"
  name          = "aws-us-east1-transit-agw"
  region        = var.aws_region-1
  single_az_ha  = false
}

module "spoke_aws_us_east1" {
  source  = "terraform-aviatrix-modules/mc-spoke/aviatrix"
  version = "1.1.0"

  account       = "aws-account"
  attached      = false
  cidr          = "10.0.12.0/23"
  cloud         = "AWS"
  ha_gw         = true
  insane_mode   = true
  instance_size = "c5n.large"
  name          = "aws-us-east1-spoke1-agw"
  region        = var.aws_region-1
  single_az_ha  = false
}

resource "azurerm_resource_group" "az-test-rg" {
  name     = "az-spoke1-rg"
  location = var.az_region
}

resource "aviatrix_vpc" "spoke_azure_us_west_1" {
  cloud_type           = 8
  account_name         = "azure-account"
  aviatrix_transit_vpc = false
  aviatrix_firenet_vpc = false
  name                 = "azure-us-west-spoke1-agw"
  region               = var.az_region
  cidr                 = "192.168.1.0/24"
}

resource "azurerm_resource_group" "az-spoke2-rg" {
  name     = "az-spoke2-rg"
  location = var.az_region
}

module "spoke_azure_us_west_2" {
  source  = "terraform-aviatrix-modules/mc-spoke/aviatrix"
  version = "1.1.0"

  cloud          = "Azure"
  name           = "azure-us-west-spoke2-agw"
  cidr           = "192.168.2.0/24"
  region         = var.az_region
  az_support     = false
  resource_group = azurerm_resource_group.az-spoke2-rg.name
  account        = "azure-account"
  ha_gw          = false
  instance_size  = "Standard_B2s"
  single_az_ha   = false
  attached       = false
}

resource "azurerm_network_security_group" "az_sg_checkpoint" {
  name                = "az_sg_west"
  location            = azurerm_resource_group.az-spoke2-rg.location
  resource_group_name = azurerm_resource_group.az-spoke2-rg.name
  security_rule {
    name                       = "allow_all"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

resource "aws_security_group" "aws-us-east2-spoke1-sg" {
  name   = "aws-us-east2-spoke1-sg"
  vpc_id = aviatrix_vpc.aws-us-east2-spoke1.vpc_id
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 31283
    to_port     = 31283
    protocol    = "udp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 5000
    to_port     = 5000
    protocol    = "udp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "allow_ssh"
  }
}

resource "aws_key_pair" "aws_east2_key" {
  key_name   = "ace_lab_east2"
  public_key = tls_private_key.avtx_key.public_key_openssh
}

# ssh to aws instance uses web console
resource "aws_instance" "aws-us-east2-spoke1-test1" {
  ami                         = var.aws_ami_lab3
  instance_type               = "t2.micro"
  subnet_id                   = aviatrix_vpc.aws-us-east2-spoke1.subnets[3].subnet_id
  private_ip                  = "10.0.1.100"
  associate_public_ip_address = true
  key_name                    = aws_key_pair.aws_east2_key.key_name
  vpc_security_group_ids      = [aws_security_group.aws-us-east2-spoke1-sg.id]
  user_data_base64            = base64encode(local.user_data_east2_spoke1_test1)

  tags = {
    Name = "aws-us-east2-spoke1-test1"
  }
}

resource "azurerm_network_security_group" "az_sg_west" {
  name                = "az_sg_west"
  location            = azurerm_resource_group.az-test-rg.location
  resource_group_name = azurerm_resource_group.az-test-rg.name
  security_rule {
    name                       = "allow_ssh"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "TCP"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
  security_rule {
    name                       = "allow_443"
    priority                   = 110
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "TCP"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
  security_rule {
    name                       = "allow_icmp"
    priority                   = 101
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "ICMP"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

resource "azurerm_public_ip" "az-public-ip" {
  name                = "az-public-ip"
  location            = azurerm_resource_group.az-test-rg.location
  resource_group_name = azurerm_resource_group.az-test-rg.name
  allocation_method   = "Dynamic"
}

resource "azurerm_network_interface" "az-test-nic" {
  name                = "az-test-nic"
  location            = azurerm_resource_group.az-test-rg.location
  resource_group_name = azurerm_resource_group.az-test-rg.name
  ip_configuration {
    name                          = "az-test-nic"
    subnet_id                     = aviatrix_vpc.spoke_azure_us_west_1.public_subnets[0].subnet_id
    private_ip_address_allocation = "Static"
    private_ip_address            = "192.168.1.10"
    public_ip_address_id          = azurerm_public_ip.az-public-ip.id
  }
}

resource "azurerm_virtual_machine" "azure-us-west-spoke1-test1" {
  name                  = "azure-us-west-spoke1-test1"
  location              = azurerm_resource_group.az-test-rg.location
  resource_group_name   = azurerm_resource_group.az-test-rg.name
  network_interface_ids = [azurerm_network_interface.az-test-nic.id]
  vm_size               = "Standard_B1ls"

  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }

  storage_os_disk {
    name          = "azure-us-west-spoke1-test1-disk"
    create_option = "FromImage"
    caching       = "ReadWrite"
  }

  os_profile {
    computer_name  = "azure-us-west-spoke1-test1"
    admin_username = "student"
    admin_password = "Aviatrix123#"
  }

  os_profile_linux_config {
    disable_password_authentication = false
  }
}

resource "azurerm_public_ip" "lab7-public-azvm-ip" {
  name                = "lab7-public-azvm-ip"
  location            = azurerm_resource_group.az-spoke2-rg.location
  resource_group_name = azurerm_resource_group.az-spoke2-rg.name
  allocation_method   = "Dynamic"
}

resource "azurerm_network_interface" "azure-us-west-spoke2-test1-nic" {
  name                = "azure-us-west-spoke2-test1-nic"
  location            = azurerm_resource_group.az-spoke2-rg.location
  resource_group_name = azurerm_resource_group.az-spoke2-rg.name
  ip_configuration {
    name                          = "azure-us-west-spoke2-test1"
    subnet_id                     = module.spoke_azure_us_west_2.vpc.public_subnets[0].subnet_id
    private_ip_address_allocation = "Static"
    private_ip_address            = "192.168.2.10"
    public_ip_address_id          = azurerm_public_ip.lab7-public-azvm-ip.id
  }
}

resource "azurerm_virtual_machine" "azure-us-west-spoke2-test1" {
  name                  = "azure-us-west-spoke2-test1"
  location              = azurerm_resource_group.az-spoke2-rg.location
  resource_group_name   = azurerm_resource_group.az-spoke2-rg.name
  network_interface_ids = [azurerm_network_interface.azure-us-west-spoke2-test1-nic.id]
  vm_size               = "Standard_B1ls"

  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }

  storage_os_disk {
    name          = "azure-us-west-spoke2-test1-disk"
    create_option = "FromImage"
    caching       = "ReadWrite"
  }

  os_profile {
    computer_name  = "azure-us-west-spoke2-test1"
    admin_username = "student"
    admin_password = "Aviatrix123#"
  }

  os_profile_linux_config {
    disable_password_authentication = false
  }
}


# resource "google_compute_network" "gcp-us-central1-spoke1" {
#   name                    = "gcp-us-central1-spoke1"
#   auto_create_subnetworks = false
# }

# resource "google_compute_subnetwork" "gcp-us-central1-spoke1-agw-sub1" {
#   name          = "gcp-us-central1-spoke1-agw-sub1"
#   ip_cidr_range = "172.16.1.0/24"
#   region        = var.gcp_region
#   network       = google_compute_network.gcp-us-central1-spoke1.id
# }

# resource "google_compute_subnetwork" "gcp-us-central1-spoke1-vm-sub2" {
#   name          = "gcp-us-central1-spoke1-vm-sub2"
#   ip_cidr_range = "172.16.2.0/24"
#   region        = var.gcp_region
#   network       = google_compute_network.gcp-us-central1-spoke1.id
# }

# resource "google_compute_firewall" "gcp-comp-firewall" {
#   name    = "gcp-comp-firewall"
#   network = google_compute_network.gcp-us-central1-spoke1.id
#   allow {
#     protocol = "icmp"
#   }
#   allow {
#     protocol = "tcp"
#     ports    = [80, 443, 22]
#   }
#   source_ranges = ["0.0.0.0/0"]
# }

# resource "google_compute_address" "gcp-us-central1-spoke1-test1-eip" {
#   name         = "gcp-us-central1-spoke1-test1-eip"
#   address_type = "EXTERNAL"
# }

# resource "google_compute_instance" "gcp-us-central1-spoke1-test1" {
#   name         = "gcp-us-central1-spoke1-test1"
#   machine_type = "n1-standard-1"
#   zone         = "us-central1-a"
#   boot_disk {
#     initialize_params {
#       image = "ubuntu-1804-bionic-v20200923"
#     }
#   }
#   network_interface {
#     network    = google_compute_network.gcp-us-central1-spoke1.id
#     subnetwork = google_compute_subnetwork.gcp-us-central1-spoke1-agw-sub1.id
#     network_ip = "172.16.1.100"
#     access_config {
#       nat_ip = google_compute_address.gcp-us-central1-spoke1-test1-eip.address
#     }
#   }
#   metadata = {
#     ssh-keys = tls_private_key.avtx_key.public_key_openssh
#   }
#   metadata_startup_script = file("./vm.sh")
# }

resource "aws_security_group" "allow_ssh_lab5" {
  provider = aws.east
  name     = "allow_ssh_lab5"
  vpc_id   = module.spoke_aws_us_east1.vpc.vpc_id
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "allow_ssh_lab5"
  }
}

resource "aws_instance" "aws-us-east1-spoke1-test1" {
  provider                    = aws.east
  ami                         = var.aws_ami_lab5
  instance_type               = "t3.micro"
  subnet_id                   = module.spoke_aws_us_east1.vpc.public_subnets[0].subnet_id
  private_ip                  = "10.0.12.42" #**********************************
  associate_public_ip_address = true
  key_name                    = aws_key_pair.aws_east1_key.key_name
  vpc_security_group_ids      = [aws_security_group.allow_ssh_lab5.id]
  user_data_base64            = base64encode(local.user_data_east1_spoke1_test1)
  tags = {
    Name = "aws-us-east1-spoke1-test1"
  }
}

resource "aws_instance" "aws-us-east1-spoke1-test2" {
  provider                    = aws.east
  ami                         = var.aws_ami_lab5
  instance_type               = "t3.micro"
  subnet_id                   = module.spoke_aws_us_east1.vpc.public_subnets[1].subnet_id
  private_ip                  = "10.0.12.52" #**********************************
  associate_public_ip_address = true
  key_name                    = aws_key_pair.aws_east1_key.key_name
  vpc_security_group_ids      = [aws_security_group.allow_ssh_lab5.id]
  user_data_base64            = base64encode(local.user_data_east1_spoke1_test2)

  tags = {
    Name = "aws-us-east1-spoke1-test2"
  }
}

# module "on-prem-partner1" {
#   providers      = { aws = aws.east }
#   source         = "terraform-aws-modules/vpc/aws"
#   name           = "on-prem-partner1"
#   cidr           = "172.16.1.0/24"
#   azs            = ["us-east-1a"]
#   public_subnets = ["172.16.1.0/24"]

#   tags = {
#     Terrafrom   = "true"
#     Environment = "ACE"
#   }
# }

# resource "aws_security_group" "on-prem-partner1" {
#   provider = aws.east
#   name     = "on-prem-partner1"
#   vpc_id   = module.on-prem-partner1.vpc_id
#   ingress {
#     from_port   = 22
#     to_port     = 22
#     protocol    = "tcp"
#     cidr_blocks = ["0.0.0.0/0"]
#   }
#   ingress {
#     from_port   = 500
#     to_port     = 500
#     protocol    = "udp"
#     cidr_blocks = ["0.0.0.0/0"]
#   }
#   ingress {
#     from_port   = 4500
#     to_port     = 4500
#     protocol    = "udp"
#     cidr_blocks = ["0.0.0.0/0"]
#   }
#   egress {
#     from_port   = 0
#     to_port     = 0
#     protocol    = -1
#     cidr_blocks = ["0.0.0.0/0"]
#   }
#   tags = {
#     Name = "on-prem-partner1"
#   }
# }

# ami id  ami-0b532148acf19dd16
# the login credential refers csh.sh which includes user-data to allow admin login
# https://discuss.hashicorp.com/t/csr1000v-userdata-works-in-v11-but-doesnt-work-in-v12/1887
# resource "aws_instance" "aws-cisco-csr" {
#   provider                    = aws.east
#   ami                         = var.aws_ami_csr_lab5
#   instance_type               = "t2.medium"
#   subnet_id                   = module.on-prem-partner1.public_subnets[0]
#   associate_public_ip_address = true
#   key_name                    = aws_key_pair.aws_east1_key.key_name
#   vpc_security_group_ids      = [aws_security_group.on-prem-partner1.id]
#   user_data                   = <<EOF
#     ios-config-100 = "username admin privilege 15 password Aviatrix123#"
#     ios-config-104 = "hostname OnPrem-Partner1"
#     ios-config-110 = "write memory"
# EOF

#   tags = {
#     Name = "aws-cisco-csr"
#   }
# }

resource "aws_key_pair" "aws_east1_key" {
  provider   = aws.east
  key_name   = "ace_lab_east1"
  public_key = tls_private_key.avtx_key.public_key_openssh

}

resource "aws_key_pair" "aws_west1_key" {
  provider   = aws.west1
  key_name   = "ace_lab_west1"
  public_key = tls_private_key.avtx_key.public_key_openssh

}

resource "tls_private_key" "avtx_key" {
  algorithm = "RSA"
  rsa_bits  = 2048
}

resource "local_file" "avtx_priv_key" {
  content         = tls_private_key.avtx_key.private_key_pem
  filename        = "avtx_priv_key.pem"
  file_permission = "0400"
}
