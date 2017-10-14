# k8s-ingress
showcase k8s cluster on aws using kops and ingress
 - - -

## Installation

### Terraform

```bash
curl -LO https://releases.hashicorp.com/terraform/0.10.7/terraform_0.10.7_darwin_amd64.zip
unzip terraform_0.10.7_darwin_amd64.zip
sudo mv terraform /usr/local/bin/terraform
terraform
```

### KOPS

```bash
echo "Download kops"

curl -LO https://github.com/kubernetes/kops/releases/download/1.7.1/kops-darwin-amd64 && chmod +x  kops-darwin-amd64 \
&& sudo mv kops-darwin-amd64 /usr/local/bin/kops \
&& echo "kops version installed is  $(kops version)"
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

`open http://localhost:8001/api/v1/namespaces/kube-system/services/https:kubernetes-dashboard:/proxy/`

## Ingress
### controller and back-end on aws

* create ingress controller (nginx) on AWS and sample app echo-header

```bash
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/master/examples/aws/nginx-ingress-controller.yaml

kubectl get services -o wide | grep nginx


kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/master/examples/echo-header.yaml

kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/master/examples/ingress.yaml
```

* Test accessing default back-end and echo-header service from ELB

ELB=$(kubectl get svc ingress-nginx -o jsonpath='{.status.loadBalancer.ingress[0].hostname}')


```bash
curl $ELB
curl $ELB/foo -H 'Host: foo.bar.com'
```

* Scale echo-headers deployment to three pods
`kubectl scale  --replicas=3 deployment/echoheaders`

* kubetail -- really useful tool to tail logs

```bash
brew tap johanhaleby/kubetail && brew install kubetail
```

* Test sticky session (tail logs of pods and create ingress for sticky session)

```bash
kubetail -l app=echoheaders

kubectl apply -f sticky-ingress.yaml
```

```bash
curl -D cookies.txt $ELB/foo -H 'Host: stickyingress.example.com'


while true; do sleep 1;curl -b cookies.txt $ELB/foo -H 'Host: stickyingress.example.com';done
```

see that requests are directed to only one pod

![Demo](https://github.com/shavo007/k8s-ingress/raw/master/stickySession.gif)

* NGINX configuration sample

```bash
kubectl exec -it <podname> bash
cat /etc/nginx/nginx.conf

upstream sticky-default-echoheaders-x-80 {
      sticky hash=sha1 name=route  httponly;
      server 100.96.2.8:8080 max_fails=0 fail_timeout=0;
      server 100.96.1.5:8080 max_fails=0 fail_timeout=0;
      server 100.96.2.7:8080 max_fails=0 fail_timeout=0;
  }
```

## Mobile app Cabin
Developed by guys at bitnami https://github.com/bitnami/cabin

!(https://github.com/shanelee007/k8s-ingress/raw/master/Cabin1.png)

!(https://github.com/shanelee007/k8s-ingress/raw/master/Cabin2.png)



## Resources

AWS Nginx ingress controller:
https://github.com/kubernetes/ingress/tree/master/controllers/nginx

Create cluster args: https://github.com/kubernetes/kops/blob/master/docs/cli/kops_create_cluster.md
