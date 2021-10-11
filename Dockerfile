# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.
FROM ubuntu:focal-20210921

ENV PANDOC_TEMPLATES_VERSION=2.14.2 \
    DEBIAN_FRONTEND=noninteractive

## Install some useful tools and dependencies for MRO
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        ca-certificates \
        build-essential \
        fontconfig \
        fonts-cardo \
        fonts-stix \
        fonts-texgyre \
        git \
        gnupg \
        gosu \
        locales \
        make \
        pandoc \
        pandoc-citeproc \
        python3-dev \
        unzip \
        wget \
    && apt-get clean

## Set environment variables
ENV LC_ALL=en_US.UTF-8 \
    LANG=en_US.UTF-8 \
    LANGUAGE=en_US.UTF-8 \
    SHELL=/bin/bash \
    CT_USER=docker \
    CT_UID=1000 \
    CT_GID=100 \
    CT_FMODE=0775 \
    FONT_LOCAL=/usr/local/share/fonts
ENV HOME=/home/${CT_USER}

## Set a default user. Available via runtime flag `--user docker`
## User should also have & own a home directory (e.g. for linked volumes to work properly).
RUN useradd --create-home --uid ${CT_UID} --gid ${CT_GID} --shell ${SHELL} \
    --password ${CT_USER} ${CT_USER}

## Install pandoc-templates.
RUN mkdir -p /opt/pandoc/templates \
  && cd /opt/pandoc/templates \
  && wget -q https://github.com/jgm/pandoc-templates/archive/${PANDOC_TEMPLATES_VERSION}.tar.gz \
  && tar xzf ${PANDOC_TEMPLATES_VERSION}.tar.gz \
  && rm ${PANDOC_TEMPLATES_VERSION}.tar.gz \
  && mkdir -p /root/.pandoc \
  && ln -s /opt/pandoc/templates /root/.pandoc/templates \
  && mkdir -p ${HOME}/.pandoc \
  && ln -s /opt/pandoc/templates ${HOME}/.pandoc/templates \
  && chown -R ${CT_USER}:${CT_GID} ${HOME}/.pandoc

COPY fonts.zip ${FONT_LOCAL}

WORKDIR ${FONT_LOCAL}

## Setup the locale
RUN unzip fonts.zip \
    && rm fonts.zip \
    && echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen \
    && locale-gen en_US.utf8 \
    && /usr/sbin/update-locale LANG=en_US.UTF-8 \
    && git clone --branch release --depth 1 \
    'https://github.com/adobe-fonts/source-code-pro.git' \
    "${FONT_LOCAL}/adobe-fonts/source-code-pro" \
    && fc-cache -f -v "${FONT_LOCAL}"

WORKDIR /root

ARG TL_VERSION=${TL_VERSION}

# Install TeX live
COPY texlive.profile /root
RUN wget ftp://mirrors.ibiblio.org/CTAN/systems/texlive/tlnet/install-tl-unx.tar.gz \
  && tar xzvf install-tl-unx.tar.gz \
  && ./install-tl-*/install-tl -profile texlive.profile \
  && rm -rf install-tl-* \
  && rm texlive.profile \
  && /usr/local/texlive/${TL_VERSION}/bin/x86_64-linux/tlmgr install \
    biber \
    biblatex \
    chktex \
    logreq \
    latexmk

ENV PATH="/usr/local/texlive/${TL_VERSION}/bin/x86_64-linux:${PATH}"

RUN ln -s /usr/bin/python3 /usr/bin/python

ARG VCS_URL=${VCS_URL}
ARG VCS_REF=${VCS_REF}
ARG BUILD_DATE=${BUILD_DATE}

# Add image metadata
LABEL org.label-schema.license="http://www.tug.org/texlive/copying.html" \
    org.label-schema.vendor="TeX Users Group (TUG)" \
    org.label-schema.name="TeXLive" \
    org.label-schema.description="Docker image of TeXLive." \
    org.label-schema.vcs-url=${VCS_URL} \
    org.label-schema.vcs-ref=${VCS_REF} \
    org.label-schema.build-date=${BUILD_DATE} \
    maintainer="Mark Coggeshall <mark.coggeshall@gmail.com>"

USER ${CT_USER}

WORKDIR ${HOME}/work

ENTRYPOINT ["/bin/bash"]
