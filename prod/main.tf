terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.13.0"
    }
    kubernetes = {
      source = "hashicorp/kubernetes"
      version = "~> 2.0.2"
    }
    helm = {
      source = "hashicorp/helm"
      version = "~> 2.0.2"
    }
  }

  backend "s3" {
    bucket         = "test-tf-state"
    key            = "lb-controller/prod"
    dynamodb_table = "test-tf-state"
    region         = "eu-central-1"
  }
}

# Additional provider section is needed to tell Terraform where and how to connect to K8S
provider "kubernetes" {
  host                   = data.aws_eks_cluster.main.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.main.certificate_authority.0.data)
  token                  = data.aws_eks_cluster_auth.main.token
}

# Additional configuration section is needed so Terraform could call Helm for specific cluster
provider "helm" {
  kubernetes {
    host                   = data.aws_eks_cluster.main.endpoint
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.main.certificate_authority.0.data)
    token                  = data.aws_eks_cluster_auth.main.token
  }
}

# OpenID connect provider is needed for AWS Load Balancer controller
resource "aws_iam_openid_connect_provider" "main" {
  url = data.aws_eks_cluster.main.identity.0.oidc.0.issuer

  client_id_list = [
    "sts.amazonaws.com"
  ]

  thumbprint_list = var.thumbprint_list
}

resource "aws_iam_policy" "lb_controller" {
  name        = "${var.eks_cluster_name}-AWSLoadBalancerControllerIAMPolicy"
  path        = "/"
  description = "AWS Load Balancer controller policy"

  policy = file("lb_controller_policy.json")
}

resource "aws_iam_role" "lb_controller" {
  name = "${var.eks_cluster_name}-eks-lb-controller-role"

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Federated": "arn:aws:iam::${var.aws_account_number}:oidc-provider/${trimprefix(data.aws_eks_cluster.main.identity.0.oidc.0.issuer, "https://")}"
      },
      "Action": "sts:AssumeRoleWithWebIdentity",
      "Condition": {
        "StringEquals": {
          "${trimprefix(data.aws_eks_cluster.main.identity.0.oidc.0.issuer, "https://")}:sub": "system:serviceaccount:kube-system:aws-load-balancer-controller"
        }
      }
    }
  ]
}
POLICY
}

resource "aws_iam_role_policy_attachment" "lb_controller" {
  policy_arn = aws_iam_policy.lb_controller.arn
  role       = aws_iam_role.lb_controller.name
}

# NOTE: hardcoded values are fine here, as we install cluster-wide component
resource "kubernetes_service_account" "lb_controller" {
  metadata {
    name = "aws-load-balancer-controller"
    namespace = "kube-system"
    labels = {
      "app.kubernetes.io/component" = "controller"
      "app.kubernetes.io/name" = "aws-load-balancer-controller"
    }
    annotations = {
      "eks.amazonaws.com/role-arn" = aws_iam_role.lb_controller.arn
    }
  }
}

# Install the TargetGroupBinding CRDs using kubectl, as Terraform does not provide other way of doing this
# NOTE: kubectl MUST be configured to point to the cluster specified in eks_cluster_name variable
resource "null_resource" "crds" {
  provisioner "local-exec" {
    command = "kubectl apply -k github.com/aws/eks-charts/stable/aws-load-balancer-controller//crds?ref=master"
  }
}

resource "helm_release" "lb_controller" {
  name       = "aws-load-balancer-controller"
  repository = "https://aws.github.io/eks-charts"
  chart      = "aws-load-balancer-controller"
  version    = "1.1.4"
  namespace  = "kube-system"

  set {
    name  = "clusterName"
    value = var.eks_cluster_name
  }

  set {
    name  = "serviceAccount.create"
    value = "false"
  }

  set {
    name  = "serviceAccount.name"
    value = kubernetes_service_account.lb_controller.metadata.0.name
  }
}
