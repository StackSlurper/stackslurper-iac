
resource "aws_route53_record" "mx1" {
  zone_id = var.zone_id
  name    = ""
  type    = "MX"
  ttl     = 300
  records = [
    "10 mx1.privateemail.com",
    "10 mx2.privateemail.com",
  ]
}

resource "aws_route53_record" "spf" {
  zone_id = var.zone_id
  name    = "@"
  type    = "TXT"
  ttl     = 300
  records = [
    "v=spf1 include:spf.privateemail.com ~all"
  ]
}

resource "aws_route53_record" "dmarc" {
  zone_id = var.zone_id
  name    = "_dmarc"
  type    = "TXT"
  ttl     = 300
  records = [
    "v=DMARC1; p=none; rua=mailto:you@stackslurper.xyz"
  ]
}

resource "aws_route53_record" "private_email_dkim" {
  zone_id = var.zone_id
  name    = "default._domainkey"
  type    = "TXT"
  ttl     = 300
  records = [
    // public key for DKIM, no need to encrypt
    "v=DKIM1; k=rsa; p=MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAxzVluVaRDrru+dQwkaV27+wmn9EuF7L\"\"cAOrMnIyORookIkPhxKGAJqtEcEorpXFLKB9/pVenGvp76Qv0P/m8Fwy384axkUPAsAJqwJp96GttVxFjXpVAcYmW1ik\"\"c5s3AqaOXpTDZn4GGqzacOZsng3KAyOukcbQzDiuHGsv7UE6+V8xuB6ATMwHym5NHUaYXXqHTsVb66kL6NU8ij4EjcY0b/\"\"AG7fhvy6kbgDKQsfRlMCo+iaXNbBfnxf4XMx/M+s4NCraSTbNq5MWuhfgxkJiB1dioDM1B/W5InL9uisIiAuOW9OYZk4++\"\"cQrAjEJJ0e2dC6d1wyEk2ScYglLKHuwIDAQAB"
  ]
}
