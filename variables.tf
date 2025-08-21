# External Secrets Operator Configuration

variable "oci_fingerprint" {
  description = "OCI Fingerprint"
  type        = string
}

variable "oci_private_key" {
  description = "OCI Private Key content"
  type        = string
  sensitive   = true
}
