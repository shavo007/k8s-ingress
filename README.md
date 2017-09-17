# k8s-ingress
showcase k8s cluster on aws using kops and ingress
 - - -

## Installation

### Terraform

```bash
curl -LO https://releases.hashicorp.com/terraform/0.10.0/terraform_0.10.0_darwin_amd64.zip
unzip terraform_0.10.0_darwin_amd64.zip
sudo mv terraform /usr/local/bin/terraform
terraform
```

### KOPS

```bash
echo "Download kops"

curl -LO https://github.com/kubernetes/kops/releases/download/1.7.0/kops-darwin-amd64 && chmod +x  kops-darwin-amd64 \
&& sudo mv kops-darwin-amd64 /usr/local/bin/kops

 echo "kops version installed is  $(kops version)"
```


## Creation of  S3 bucket

```bash

terraform init -- Initialization (install the plugins for aws provider)
terraform plan -- Dry run
terraform apply -- Run
terraform show -- Inspect state

```

## Create cluster

```bash
./deploy.sh
```


### Export kube configuration
`kops export kubecfg ${NAME}`

### dashboard
`kubectl proxy`

`open http://localhost:8001/ui`

## Ingress
### controller and back-end on aws

* create ingress controller on aws and sample app echo-header

```bash
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress/master/examples/aws/nginx/nginx-ingress-controller.yaml

kubectl get services -o wide | grep nginx


kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress/master/controllers/nginx/examples/echo-header.yaml

kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress/master/controllers/nginx/examples/ingress.yaml
```

* Test accessing default back-end and echo-header service from ELB

```bash
curl a19e65dc19ad711e786180662c36692e-1900213592.ap-southeast-2.elb.amazonaws.com
curl a19e65dc19ad711e786180662c36692e-1900213592.ap-southeast-2.elb.amazonaws.com/foo -H 'Host: foo.bar.com'
```

* Scale echo-headers deployment to three pods

* Install kubetail

```bash
brew tap johanhaleby/kubetail && brew install kubetail
```

* Test sticky session (tail logs of pods and create ingress for sticky session)

```bash
kubetail -l app=echoheaders

kubectl apply -f sticky-ingress.yaml
```

curl -I a19e65dc19ad711e786180662c36692e-1900213592.ap-southeast-2.elb.amazonaws.com/foo -H 'Host: stickyingress.example.com' (or in postman)

see that requests are directed to only one pod

nginx configuration
kubectl exec -it ingress-nginx-1623274871-1j9fb bash
cat /etc/nginx/nginx.conf

upstream sticky-default-echoheaders-x-80 {
      sticky hash=sha1 name=route  httponly;
      server 100.96.2.8:8080 max_fails=0 fail_timeout=0;
      server 100.96.1.5:8080 max_fails=0 fail_timeout=0;
      server 100.96.2.7:8080 max_fails=0 fail_timeout=0;
  }


## Resources

AWS Nginx ingress controller:
https://github.com/kubernetes/ingress/tree/master/controllers/nginx

Create cluster args: https://github.com/kubernetes/kops/blob/master/docs/cli/kops_create_cluster.md
