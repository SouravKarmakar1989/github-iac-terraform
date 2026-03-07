location      = "centralus"
env           = "dev"
prefix        = "sk"
address_space = ["10.0.0.0/16"]
subnets = {
  default = { address_prefix = "10.0.1.0/24" }
  app     = { address_prefix = "10.0.2.0/24" }
  data    = { address_prefix = "10.0.3.0/24" }
}
