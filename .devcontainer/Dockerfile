# See here for image contents: https://github.com/microsoft/vscode-dev-containers/tree/v0.177.0/containers/dotnet/.devcontainer/base.Dockerfile

FROM mcr.microsoft.com/vscode/devcontainers/dotnet:5.0

# install Azure CLI
RUN curl -sL https://aka.ms/InstallAzureCLIDeb | bash

# install Docker
RUN curl -fsSL https://get.docker.com | bash

# install PowerShell
RUN wget https://packages.microsoft.com/config/debian/10/packages-microsoft-prod.deb \
    && dpkg -i packages-microsoft-prod.deb \
    && rm packages-microsoft-prod.deb \
    && apt-get update \
    && apt-get install -y powershell

# install Bicep
RUN curl -Lo /usr/local/bin/bicep https://github.com/Azure/bicep/releases/latest/download/bicep-linux-x64 \
    && chmod +x /usr/local/bin/bicep \
    && apt-get clean -y && rm -rf /var/lib/apt/lists/* /tmp/library-scripts

RUN apt-get update \
    && apt-get -y install --no-install-recommends \
        apt-utils \ 
        dialog \
        git \
        iproute2 \
        procps \
        curl \
        apt-transport-https \
        gnupg2 \
        lsb-release \
        jq \
        software-properties-common \
        zip

    # install Azure CLI extensions
RUN az aks install-cli \
    && az extension add -n application-insights \
    && az extension add --upgrade --yes -n connectedk8s \
    && az extension add --upgrade --yes -n customlocation \
    && az extension add --upgrade --yes -n k8s-extension \
    && az extension add --yes --source "https://aka.ms/appsvc/appservice_kube-latest-py2.py3-none-any.whl" \
    # install Helm
    && curl https://baltocdn.com/helm/signing.asc | apt-key add \ 
    && echo "deb https://baltocdn.com/helm/stable/debian/ all main" | tee /etc/apt/sources.list.d/helm-stable-debian.list \
    && apt-get update \
    && apt-get install -y helm=3.5.0-1 \
    && localedef -i en_US -c -f UTF-8 -A /usr/share/locale/locale.alias en_US.UTF-8 \
    # install k9s
    && mkdir -p /home/${USERNAME}/.k9s \
    && K9S_VERSION=$(basename "$(curl -fsSL -o /dev/null -w "%{url_effective}" https://github.com/derailed/k9s/releases/latest)") \
    && curl -Lo ./k9s.tar.gz https://github.com/derailed/k9s/releases/download/${K9S_VERSION}/k9s_Linux_x86_64.tar.gz \
    && mkdir k9s \
    && tar xvzf k9s.tar.gz -C ./k9s \
    && chmod 755 ./k9s/k9s \
    && mv ./k9s/k9s /usr/local/bin/k9s \
    && rm -rf k9s.tar.gz k9s

# create dev cert
RUN dotnet dev-certs https
ENV LANG en_US.UTF-8

# Uncomment for using docker without a WSL backend.
# ENV DOCKER_HOST=tcp://host.docker.internal:2375
