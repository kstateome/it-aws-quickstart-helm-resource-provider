FROM lambci/lambda:build-python3.8

# https://docs.aws.amazon.com/eks/latest/userguide/install-kubectl.html
# N-1 version strategy for maximum interop coverage
ENV VERSION="1.23.15/2023-01-11"

COPY . /build

WORKDIR /build

RUN cd src && zip -r -q ../ResourceProvider.zip ./ && \
    cd ../ && \
    mv awsqs-kubernetes-helm.json schema.json && \
    find . -exec touch -t 202007010000.00 {} + && \
    zip -X -r -q ./awsqs_kubernetes_helm.zip ./ResourceProvider.zip schema.json .rpdk-config

RUN ls
CMD mkdir -p /output/ && mv /build/*.zip /output/
