# How to use

1. Fetch this repository;
2. Ensure that `OS_` variables are set, so terraform can access your cloud;
3. Install latest terraform;
4. Run terraform in the root of that repository:
```
$ terraform init
$ terraform apply
```

Enjoy multi-region setup with 2 VMs, that can reach each other by private IP
addresses via IPsec VPN as a Service!