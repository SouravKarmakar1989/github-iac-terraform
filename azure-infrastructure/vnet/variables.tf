variable "location"      { type = string }
variable "env"           { type = string }
variable "prefix"        { type = string }

variable "address_space" {
  type        = list(string)
  default     = ["10.0.0.0/16"]
  description = "CIDR address space for the VNet"
}

variable "subnets" {
  type = map(object({
    address_prefix = string
  }))
  default = {
    default = { address_prefix = "10.0.1.0/24" }
  }
  description = "Map of subnet name → address_prefix. Key becomes part of the subnet resource name."
}
