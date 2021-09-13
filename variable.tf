variable "vpc-cidr" {
  default = "10.200.0.0/16"
  description = "VPC CIDR Block"
  type = string
}

variable "public-subnet1-cidr" {
  default = "10.200.1.0/24"
  description = "Public Subnet1 CIDR Block"
  type = string
}

variable "public-subnet2-cidr" {
  default = "10.200.2.0/24"
  description = "Public Subnet2 CIDR Block"
  type = string
}

variable "private-subnet1-cidr" {
  default = "10.200.3.0/24"
  description = "Private Subnet1 CIDR Block"
  type = string
}

variable "private-subnet2-cidr" {
  default = "10.200.4.0/24"
  description = "Private Subnet2 CIDR Block"
  type = string
}
