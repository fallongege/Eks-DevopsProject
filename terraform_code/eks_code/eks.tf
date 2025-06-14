module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.31"

  cluster_name                   = local.name
  cluster_endpoint_public_access = true

  cluster_addons = {
    coredns = {
      most_recent = true
    }
    kube-proxy = {
      most_recent = true
    }
    vpc-cni = {
      most_recent = true
    }
  }

  vpc_id                   = aws_vpc.main.id
  subnet_ids               = aws_subnet.public.*.id

  eks_managed_node_groups = {
    panda-node = {
      min_size     = 2
      max_size     = 4
      desired_size = 2

      instance_types = ["t2.medium"]
      capacity_type  = "SPOT"

      tags = merge({
        ExtraTag = "Panda_Node"
      }, local.general_tags)
    }
  }

  tags = local.name != "" ? merge(local.general_tags, { Name = local.name }) : local.general_tags
}
