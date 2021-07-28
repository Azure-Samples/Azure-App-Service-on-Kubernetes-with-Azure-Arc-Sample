# See here for image contents: https://github.com/microsoft/vscode-dev-containers/tree/v0.177.0/containers/dotnet/.devcontainer/base.Dockerfile

# [Choice] .NET version: 5.0, 3.1, 2.1
ARG VARIANT="5.0"
FROM mcr.microsoft.com/vscode/devcontainers/dotnet:${VARIANT}

# copy library scripts to execute
COPY library-scripts/*.sh library-scripts/*.env /tmp/library-scripts/

# install Azure CLI
ARG INSTALL_AZURE_CLI="true"
RUN if [ "$INSTALL_AZURE_CLI" = "true" ]; then bash /tmp/library-scripts/azcli-debian.sh; fi \
    && apt-get clean -y && rm -rf /var/lib/apt/lists/*

# install PowerShell
RUN wget https://packages.microsoft.com/config/debian/10/packages-microsoft-prod.deb \
    && dpkg -i packages-microsoft-prod.deb \
    && rm packages-microsoft-prod.deb \
    && apt-get update \
    && apt-get install -y powershell

# install Bicep
RUN bash /tmp/library-scripts/azcli-debian.sh \
    && curl -Lo /usr/local/bin/bicep https://github.com/Azure/bicep/releases/latest/download/bicep-linux-x64 \
    && chmod +x /usr/local/bin/bicep \
    && apt-get clean -y && rm -rf /var/lib/apt/lists/* /tmp/library-scripts

# remove library scripts for final image
RUN rm -rf /tmp/library-scripts

RUN apt-get update \
    && apt-get -y install --no-install-recommends apt-utils dialog 2>&1 \
    #
    # verify git and needed tools are installed
    && apt-get -y install \
        git \
        iproute2 \
        procps \
        curl \
        apt-transport-https \
        gnupg2 \
        lsb-release \
        jq \
        software-properties-common \
        zip \
        docker \
    # install Azure CLI extensions
    && echo "deb [arch=amd64] https://packages.microsoft.com/repos/azure-cli/ $(lsb_release -cs) main" > /etc/apt/sources.list.d/azure-cli.list \
    && curl -sL https://packages.microsoft.com/keys/microsoft.asc | (OUT=$(apt-key add - 2>&1) || echo $OUT) \
    && az aks install-cli \
    && az extension add -n application-insights \
    && az extension add --upgrade --yes -n connectedk8s \
    && az extension add --upgrade --yes -n customlocation \
    && az extension add --upgrade --yes -n k8s-extension \
    && az extension add --yes --source "https://aka.ms/appsvc/appservice_kube-latest-py2.py3-none-any.whl" \
    # install Docker CLI
    && curl -fsSL https://download.docker.com/linux/$(lsb_release -is | tr '[:upper:]' '[:lower:]')/gpg | apt-key add - 2>/dev/null \
    && echo "deb [arch=amd64] https://download.docker.com/linux/$(lsb_release -is | tr '[:upper:]' '[:lower:]') $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list \
    && apt-get update \
    && apt-get install -y docker-ce-cli \
    # install Helm
    && curl https://baltocdn.com/helm/signing.asc | apt-key add \ 
    && echo "deb https://baltocdn.com/helm/stable/debian/ all main" | tee /etc/apt/sources.list.d/helm-stable-debian.list \
    && apt-get update \
    && apt-get install -y helm=3.5.0-1


ENV DOCKER_HOST=tcp://host.docker.internal:2375
