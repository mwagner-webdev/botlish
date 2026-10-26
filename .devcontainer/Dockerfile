FROM ubuntu:26.04

ARG USERNAME=vscode
ARG USER_UID=1000
ARG USER_GID=${USER_UID}

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        build-essential \
        ca-certificates \
        curl \
        git \
        libssl-dev \
        pkg-config \
        procps \
        sudo \
        tar \
        xz-utils \
        zsh \
    && rm -rf /var/lib/apt/lists/* \
    && if ! getent group "${USER_GID}" >/dev/null; then \
        groupadd --gid "${USER_GID}" "${USERNAME}"; \
    fi \
    && existing_user="$(getent passwd "${USER_UID}" | cut -d: -f1 || true)" \
    && if getent passwd "${USERNAME}" >/dev/null; then \
        usermod --gid "${USER_GID}" --shell /usr/bin/zsh "${USERNAME}"; \
    elif [ -n "${existing_user}" ]; then \
        usermod --login "${USERNAME}" "${existing_user}"; \
        usermod --gid "${USER_GID}" --shell /usr/bin/zsh "${USERNAME}"; \
        existing_home="$(getent passwd "${USERNAME}" | cut -d: -f6)"; \
        if [ "${existing_home}" != "/home/${USERNAME}" ]; then \
            usermod --home "/home/${USERNAME}" --move-home "${USERNAME}"; \
        fi; \
    else \
        useradd --uid "${USER_UID}" --gid "${USER_GID}" --create-home \
            --shell /usr/bin/zsh "${USERNAME}"; \
    fi \
    && printf '%s ALL=(ALL) NOPASSWD:ALL\n' "${USERNAME}" \
        > "/etc/sudoers.d/${USERNAME}" \
    && chmod 0440 "/etc/sudoers.d/${USERNAME}"

USER vscode