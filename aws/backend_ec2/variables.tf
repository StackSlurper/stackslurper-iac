variable "dev_ssh_keys" {
  description = "List of developer public SSH keys"
  type        = list(string)
  default = [
    "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCWKCBIE+Hpd0MaTYK4JsBbERaUfZ11vdNTEvYNeLrGeMcJiU9CPblbA5hlpz3Z809BYCpsM+uVAq2mfCuU7nWYSSbNs3JRlB1eO0zODQGB4FpVuNt5c/8mTeVm40W8LXu9RBqzxfElbGSbhzj+HKKZX/boiqNETBZgLImczsp2+EMRNxCSVbDW5DVkZLYvHwsuazrWRG1DC/F27x91UstMR2CIXQDDonQyu3oudTSJljjS/9Oy/UQpN8za0UXle+EMZD6CyUxIv1Od/4owBxXM2LF0y/PytCU7cA1R4jxf0aJFmIrzWfadgoB4DLKMfBPJHs8waCEUTkLvZbfEXZF0p3r6rz2vyDuSysLK8ux2cA6Fpv5xH2IJRJkv/HPFKNi8ceIKtCCuRsS+7h06Eg6H+S0fG2osxV+ITHeq3aRdZEbTeGEoRKCcHhWTZXW9nInlMaAM2ijVySu7Oznu8zQNFETH6quMagvzt1qooMju6WAMNhUfVqg7PsNEG3EVkSs= terraform-ec2",

    # Add more later for teammates
  ]
}
