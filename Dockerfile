# Docker image for the Drone Terraform plugin
#
#     docker build -t jmccann/drone-terraform:latest .
FROM golang:1.14-alpine AS builder

RUN apk add --no-cache git

WORKDIR /tmp/drone-terraform
COPY . .

RUN go mod download
RUN CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -a -tags netgo -o /go/bin/drone-terraform
RUN source version.sh && \
    wget -q https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_${TERRAFORM_OS}.zip -O terraform.zip && \
    unzip terraform.zip -d /bin

FROM alpine:3.12

RUN apk add --no-cache \
    ca-certificates \
    git \
    openssh-client

COPY --from=builder /go/bin/drone-terraform /bin/terraform /bin/
ENTRYPOINT ["/bin/drone-terraform"]
