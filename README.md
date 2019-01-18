Original Docker file taken from MS:

- https://github.com/Microsoft/vsts-agent-docker/tree/master/ubuntu/16.04
- https://hub.docker.com/r/microsoft/vsts-agent



Spin up an Azure Container Instance that registers with your Azure DevOps account via an agent that has the capability to utilise Ansible, Packer and Terraform.

Creating the image via Packer (packer.json) creates a smaller image with fewer layers as opposed to using the Dockerfile.