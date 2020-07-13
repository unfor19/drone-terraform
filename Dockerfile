# Docker image for the Drone Terraform plugin
#
#     docker build -t jmccann/drone-terraform:latest .
FROM golang:1.13-alpine AS builder

RUN apk add --no-cache git

WORKDIR /tmp/drone-terraform

COPY go.mod go.mod
COPY go.sum go.sum
RUN go mod download

COPY . .

RUN CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -a -tags netgo -o /go/bin/drone-terraform

RUN source version.sh && \
    wget -q https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_${TERRAFORM_OS}.zip -O terraform.zip && \
    unzip terraform.zip -d /bin

FROM alpine:3.11

RUN apk add --no-cache \
    ca-certificates \
    git \
    wget \
    openssh-client

COPY --from=builder /go/bin/drone-terraform /bin/terraform /bin/
ENTRYPOINT ["/bin/drone-terraform"]
