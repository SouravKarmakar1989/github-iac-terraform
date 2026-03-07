location      = "centralus"
env           = "prod"
prefix        = "sk"
address_space = ["10.2.0.0/16"]
subnets = {
  default = { address_prefix = "10.2.1.0/24" }
  app     = { address_prefix = "10.2.2.0/24" }
  data    = { address_prefix = "10.2.3.0/24" }
}
