FROM microsoft/vsts-agent:ubuntu-16.04

RUN apt-get update
RUN apt-add-repository -y --update ppa:ansible/ansible
RUN apt-get install unzip -y && apt-get install software-properties-common -y && apt-get install ansible -y

RUN mkdir /files && mkdir /files/terraform && mkdir /files/packer && chmod -R 777 /files

WORKDIR /files/terraform
RUN curl https://releases.hashicorp.com/terraform/0.11.11/terraform_0.11.11_linux_amd64.zip --output terraform_0.11.11_linux_amd64.zip && unzip terraform_0.11.11_linux_amd64.zip
RUN mv terraform /usr/local/bin/

WORKDIR /files/packer
RUN curl https://releases.hashicorp.com/packer/1.3.2/packer_1.3.2_linux_arm64.zip --output packer_1.3.2_linux_arm64.zip && unzip packer_1.3.2_linux_arm64.zip
RUN mv packer /usr/local/bin/

RUN rm -rf /files

WORKDIR /vsts
CMD ["./start.sh"]