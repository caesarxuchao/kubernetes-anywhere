FROM centos:7
LABEL works.weave.role=system

ENV DOCKER_HOST=unix:///weave.sock

RUN yum --assumeyes --quiet install docker openssl

RUN curl --silent --location \
  https://storage.googleapis.com/kubernetes-release/release/v1.1.3/bin/linux/amd64/kubectl \
  --output /usr/bin/kubectl \
  && chmod +x /usr/bin/kubectl ;

RUN curl --silent --location \
  https://github.com/OpenVPN/easy-rsa/releases/download/3.0.1/EasyRSA-3.0.1.tgz \
  | tar xz -C /opt \
  && ln -s /opt/EasyRSA-3.0.1 /opt/EasyRSA

RUN kubectl config set-cluster default-cluster --server=http://kube-apiserver.weave.local:8080 ; \
   kubectl config set-context default-system --cluster=default-cluster ; \
   kubectl config use-context default-system ;

RUN mkdir guestbook-example ; cd guestbook-example ; \
  curl --silent --location \
    'https://raw.github.com/kubernetes/kubernetes/v1.1.3/examples/guestbook/{redis-master-controller,redis-master-service,redis-slave-controller,redis-slave-service,frontend-controller,frontend-service}.yaml' \
    --remote-name ; \
  sed 's/# type: LoadBalancer/type: NodePort/' -i frontend-service.yaml ;

ADD skydns-addon /skydns-addon

RUN curl --silent --location \
  https://github.com/docker/compose/releases/download/1.5.1/docker-compose-Linux-x86_64 \
  --output /usr/bin/compose \
  && chmod +x /usr/bin/compose ;

ADD docker-compose.yml /

ADD setup-kubelet-volumes.sh /usr/bin/setup-kubelet-volumes
ADD setup-secure-cluster-conf-volumes.sh /usr/bin/setup-secure-cluster-conf-volumes