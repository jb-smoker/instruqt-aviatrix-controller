resource "aws_iam_user" "student" {
  name = "student"
}

resource "aws_iam_policy" "aviatrix_ec2poweroff" {
  name        = "aviatrix-EC2PowerOff"
  description = "Aviatrix HA Test"
  policy      = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "VisualEditor0",
      "Effect": "Allow",
      "Action": [
        "ec2:RebootInstances",
        "ec2:StartInstances",
        "ec2:StopInstances"
      ],
      "Resource": "arn:aws:ec2:*:${data.aws_caller_identity.current.account_id}:instance/${module.spoke_aws_us_east1.aviatrix_spoke_gateway.aws-us-east1-spoke1-agw.cloud_instance_id}"
    },
    {
      "Sid": "VisualEditor1",
      "Effect": "Allow",
      "Action": [
        "ec2:DescribeInstances",
        "ec2:DescribeCoipPools",
        "ec2:DescribeSnapshots",
        "ec2:DescribeLocalGatewayVirtualInterfaces",
        "ec2:DescribeHostReservationOfferings",
        "ec2:DescribeTrafficMirrorSessions",
        "ec2:DescribeExportImageTasks",
        "ec2:DescribeTrafficMirrorFilters",
        "ec2:DescribeVolumeStatus",
        "ec2:DescribeLocalGatewayRouteTableVpcAssociations",
        "ec2:DescribeVolumes",
        "ec2:DescribeFpgaImageAttribute",
        "ec2:DescribeExportTasks",
        "ec2:DescribeTransitGatewayMulticastDomains",
        "ec2:DescribeManagedPrefixLists",
        "ec2:DescribeKeyPairs",
        "ec2:DescribeReservedInstancesListings",
        "ec2:DescribeCapacityReservations",
        "ec2:DescribeClientVpnRoutes",
        "ec2:DescribeSpotFleetRequestHistory",
        "ec2:DescribeVpcClassicLinkDnsSupport",
        "ec2:DescribeSnapshotAttribute",
        "ec2:DescribeIdFormat",
        "ec2:DescribeVolumeAttribute",
        "ec2:DescribeImportSnapshotTasks",
        "ec2:DescribeLocalGatewayVirtualInterfaceGroups",
        "ec2:DescribeVpcEndpointServicePermissions",
        "ec2:DescribeTransitGatewayAttachments",
        "ec2:SearchLocalGatewayRoutes",
        "ec2:DescribeImageAttribute",
        "ec2:DescribeFleets",
        "ec2:DescribeReservedInstancesModifications",
        "ec2:DescribeSubnets",
        "ec2:DescribeMovingAddresses",
        "ec2:DescribeFleetHistory",
        "ec2:DescribePrincipalIdFormat",
        "ec2:DescribeFlowLogs",
        "ec2:DescribeRegions",
        "ec2:DescribeTransitGateways",
        "ec2:DescribeVpcEndpointServices",
        "ec2:DescribeSpotInstanceRequests",
        "ec2:DescribeVpcAttribute",
        "ec2:ExportClientVpnClientCertificateRevocationList",
        "ec2:DescribeInstanceTypeOfferings",
        "ec2:DescribeTrafficMirrorTargets",
        "ec2:DescribeTransitGatewayRouteTables",
        "ec2:DescribeAvailabilityZones",
        "ec2:DescribeNetworkInterfaceAttribute",
        "ec2:DescribeLocalGatewayRouteTables",
        "ec2:DescribeVpcEndpointConnections",
        "ec2:SearchTransitGatewayMulticastGroups",
        "ec2:DescribeInstanceStatus",
        "ec2:DescribeHostReservations",
        "ec2:DescribeBundleTasks",
        "ec2:DescribeIdentityIdFormat",
        "ec2:DescribeClassicLinkInstances",
        "ec2:DescribeVpcEndpointConnectionNotifications",
        "ec2:DescribeSecurityGroups",
        "ec2:DescribeFpgaImages",
        "ec2:DescribeVpcs",
        "ec2:DescribeStaleSecurityGroups",
        "ec2:DescribeAggregateIdFormat",
        "ec2:ExportClientVpnClientConfiguration",
        "ec2:DescribeClientVpnConnections",
        "ec2:DescribeByoipCidrs",
        "ec2:DescribePlacementGroups",
        "ec2:DescribeInternetGateways",
        "ec2:SearchTransitGatewayRoutes",
        "ec2:DescribeSpotDatafeedSubscription",
        "ec2:DescribeAccountAttributes",
        "ec2:DescribeNetworkInterfacePermissions",
        "ec2:DescribeReservedInstances",
        "ec2:DescribeNetworkAcls",
        "ec2:DescribeRouteTables",
        "ec2:DescribeClientVpnEndpoints",
        "ec2:DescribeEgressOnlyInternetGateways",
        "ec2:DescribeLaunchTemplates",
        "ec2:DescribeVpcPeeringConnections",
        "ec2:DescribeReservedInstancesOfferings",
        "ec2:GetTransitGatewayAttachmentPropagations",
        "ec2:DescribeFleetInstances",
        "ec2:DescribeClientVpnTargetNetworks",
        "ec2:DescribeVpcEndpointServiceConfigurations",
        "ec2:DescribePrefixLists",
        "ec2:DescribeInstanceCreditSpecifications",
        "ec2:DescribeVpcClassicLink",
        "ec2:DescribeLocalGatewayRouteTableVirtualInterfaceGroupAssociations",
        "ec2:GetTransitGatewayRouteTablePropagations",
        "ec2:DescribeInstanceTypes",
        "ec2:DescribeVpcEndpoints",
        "ec2:DescribeVpnGateways",
        "ec2:DescribeTransitGatewayPeeringAttachments",
        "ec2:DescribeAddresses",
        "ec2:DescribeInstanceAttribute",
        "ec2:DescribeDhcpOptions",
        "ec2:DescribeSpotPriceHistory",
        "ec2:DescribeNetworkInterfaces",
        "ec2:DescribeCarrierGateways",
        "ec2:GetTransitGatewayRouteTableAssociations",
        "ec2:DescribeIamInstanceProfileAssociations",
        "ec2:DescribeLaunchTemplateVersions",
        "ec2:DescribeImportImageTasks",
        "ec2:GetTransitGatewayPrefixListReferences",
        "ec2:DescribeNatGateways",
        "ec2:DescribeCustomerGateways",
        "ec2:DescribeInstanceEventNotificationAttributes",
        "ec2:DescribeLocalGateways",
        "ec2:DescribeSpotFleetRequests",
        "ec2:DescribeHosts",
        "ec2:DescribeImages",
        "ec2:DescribeSpotFleetInstances",
        "ec2:DescribeSecurityGroupReferences",
        "ec2:DescribePublicIpv4Pools",
        "ec2:DescribeClientVpnAuthorizationRules",
        "ec2:DescribeTransitGatewayVpcAttachments",
        "ec2:GetTransitGatewayMulticastDomainAssociations",
        "ec2:DescribeConversionTasks"
      ],
      "Resource": "*"
    }
  ]
}
EOF
}

resource "aws_iam_policy_attachment" "aviatrix_ec2poweroff" {
  name       = "aviatrix-EC2PowerOff"
  users      = [aws_iam_user.student.name]
  policy_arn = aws_iam_policy.aviatrix_ec2poweroff.arn
}

resource "aws_iam_policy_attachment" "aws_readonly" {
  name       = "ReadOnlyAccess"
  users      = [aws_iam_user.student.name]
  policy_arn = "arn:aws:iam::aws:policy/ReadOnlyAccess"
}

resource "null_resource" "student_password" {
  provisioner "local-exec" {
    command     = <<-EOT
      aws iam create-login-profile --user-name=${aws_iam_user.student.name} --password=${var.aviatrix_password} --no-password-reset-required --profile ${terraform.workspace}
    EOT
    interpreter = ["/bin/bash", "-c"]
  }
}
