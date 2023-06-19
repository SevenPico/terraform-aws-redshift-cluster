locals {
  enabled = module.context.enabled
}

resource "aws_redshift_cluster" "default" {
  #checkov:skip=CKV_AWS_321:skipping 'Ensure Redshift clusters use enhanced VPC routing' because it can be configured through 'var.enhanced_vpc_routing'
  #checkov:skip=CKV_AWS_71:skipping 'Ensure Redshift Cluster logging is enabled' because it can be enabled through 'var.logging_enabled'
  #checkov:skip=CKV_AWS_141:skipping 'Ensure that redshift cluster allowing version upgrade by default' because it can be enabled through 'var.allow_version_upgrade'
  #checkov:skip=CKV_AWS_64:skipping 'Ensure all data stored in the Redshift cluster is securely encrypted at rest' because it can be configured through 'var.encrypted'
  count = local.enabled ? 1 : 0

  cluster_identifier = var.cluster_identifier == "" ? module.context.id : var.cluster_identifier
  database_name      = var.database_name
  master_username    = var.admin_user
  master_password    = var.admin_password
  node_type          = var.node_type
  cluster_type       = var.cluster_type

  vpc_security_group_ids               = var.vpc_security_group_ids
  cluster_subnet_group_name            = join("", aws_redshift_subnet_group.default[*].id)
  availability_zone                    = var.availability_zone
  availability_zone_relocation_enabled = var.availability_zone_relocation_enabled
  preferred_maintenance_window         = var.preferred_maintenance_window

  cluster_parameter_group_name        = join("", aws_redshift_parameter_group.default[*].id)
  automated_snapshot_retention_period = var.automated_snapshot_retention_period
  port                                = var.port
  cluster_version                     = var.engine_version
  number_of_nodes                     = var.number_of_nodes
  publicly_accessible                 = var.publicly_accessible
  encrypted                           = var.encrypted
  enhanced_vpc_routing                = var.enhanced_vpc_routing
  kms_key_id                          = var.kms_key_arn
  elastic_ip                          = var.elastic_ip
  skip_final_snapshot                 = var.skip_final_snapshot
  final_snapshot_identifier           = var.final_snapshot_identifier
  snapshot_identifier                 = var.snapshot_identifier
  snapshot_cluster_identifier         = var.snapshot_cluster_identifier
  owner_account                       = var.owner_account
  iam_roles                           = var.iam_roles
  allow_version_upgrade               = var.allow_version_upgrade

  logging {
    enable        = var.logging_enabled
    bucket_name   = var.logging_bucket_name
    s3_key_prefix = var.logging_s3_key_prefix
  }

  depends_on = [
    aws_redshift_subnet_group.default,
    aws_redshift_parameter_group.default
  ]

  tags = module.context.tags
}

resource "aws_redshift_subnet_group" "default" {
  count = local.enabled ? 1 : 0

  name        = module.context.id
  subnet_ids  = var.subnet_ids
  description = "Allowed subnets for Redshift Subnet group"

  tags = module.context.tags
}

resource "aws_redshift_parameter_group" "default" {
  #checkov:skip=CKV_AWS_105:skipping 'Ensure Redshift uses SSL' because it can be configured through 'var.cluster_parameters'
  count = local.enabled ? 1 : 0

  name   = module.context.id
  family = "redshift-1.0"

  dynamic "parameter" {
    for_each = var.cluster_parameters
    content {
      name  = parameter.value.name
      value = parameter.value.value
    }
  }

  tags = module.context.tags
}
