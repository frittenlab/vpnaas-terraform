# IPsec IKEv1 PSK
variable "ipsec_psk" {
  type    = "string"
  default = "super_secret"
}

# Public key to access example instances
variable "public_key" {
  type    = "string"
  default = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCj5yHe82xC8UcFMOdfWBQSgpPcMdxd+72KlaDVDU7rA6h+cYztCOLHb82ZZyfsu8jBDRVwLQG18bH+2cz47+UqIPd9emN76a3V0WY1PspxdXfEWje38iF4k/7HYPb1KUyoEdaHibwKECnLx8Y3vLE/eXHq8H7gH9LDB+qrWX7ZklXPwu1iEuOmMtZu7coargA0ayJ/3yGpNcv3ZcWbGJf28TSh/B4Lk+GkXhYm7nJXtV6MBKSamz0LYUXI0WHCyB0lTkmoISincy8CVcKMaol1TckjysChy1A7SSz9SoPI7XWMJqHYlNK94MbaOCnAkuzbiYy8l8XWcUwqjhjhHHlN Simon"
}

# Region configuration
provider "openstack" {
  region = "dbl"
  alias  = "dbl"
}

provider "openstack" {
  region = "cbk"
  alias  = "cbk"
}

# Deploy infrastructure to CBK
module "network_cbk" {
  source = "./modules/network"
  region = "cbk"
  cidr   = "10.100.1.0/24"
}

module "application_cbk" {
  source     = "./modules/simple-app"
  region     = "cbk"
  public_key = "${var.public_key}"
}

# Deploy infrastructure to DBL
module "network_dbl" {
  source = "./modules/network"
  region = "dbl"
  cidr   = "10.100.2.0/24"
}

module "application_dbl" {
  source     = "./modules/simple-app"
  region     = "dbl"
  public_key = "${var.public_key}"
}

# VPN Site-to-Site connections
resource "openstack_vpnaas_site_connection_v2" "cbk_to_dbl" {
  name           = "CBK to DBL"
  provider       = "openstack.cbk"
  vpnservice_id  = "${module.network_cbk.vpnservice_id}"
  ikepolicy_id   = "${module.network_cbk.ikepolicy_id}"
  ipsecpolicy_id = "${module.network_cbk.ipsecpolicy_id}"
  peer_id        = "${module.network_dbl.peer_id}"
  peer_address   = "${module.network_dbl.peer_id}"
  psk            = "${var.ipsec_psk}"
  peer_cidrs     = ["${module.network_dbl.cidr}"]
  admin_state_up = "true"
}

resource "openstack_vpnaas_site_connection_v2" "dbl_to_cbk" {
  name           = "DBL to CBK"
  provider       = "openstack.dbl"
  vpnservice_id  = "${module.network_dbl.vpnservice_id}"
  ikepolicy_id   = "${module.network_dbl.ikepolicy_id}"
  ipsecpolicy_id = "${module.network_dbl.ipsecpolicy_id}"
  peer_id        = "${module.network_cbk.peer_id}"
  peer_address   = "${module.network_cbk.peer_id}"
  psk            = "${var.ipsec_psk}"
  peer_cidrs     = ["${module.network_cbk.cidr}"]
  admin_state_up = "true"
}
