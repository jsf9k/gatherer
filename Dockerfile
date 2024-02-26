ARG VERSION=unspecified

# Official Docker images are in the form library/<app> while non-official
# images are in the form <user>/<app>.
FROM docker.io/library/python:3.12.0-alpine3.18

ARG VERSION

###
# For a list of pre-defined annotation keys and value types see:
# https://github.com/opencontainers/image-spec/blob/master/annotations.md
#
# Note: Additional labels are added by the build workflow.
###
# github@cisa.dhs.gov is a very generic email distribution, and it is
# unlikely that anyone on that distribution is familiar with the
# particulars of your repository.  It is therefore *strongly*
# suggested that you use an email address here that is specific to the
# person or group that maintains this repository; for example:
# LABEL org.opencontainers.image.authors="vm-fusion-dev-group@trio.dhs.gov"
LABEL org.opencontainers.image.authors="github@cisa.dhs.gov"
LABEL org.opencontainers.image.vendor="Cybersecurity and Infrastructure Security Agency"

###
# Unprivileged user setup variables
###
ARG CISA_UID=421
ARG CISA_GID=${CISA_UID}
ARG CISA_USER="cisa"
ENV CISA_GROUP=${CISA_USER}
ENV CISA_HOME="/home/${CISA_USER}"

# Versions of the Python packages installed directly
ENV PYTHON_PIP_VERSION=24.0
ENV PYTHON_SETUPTOOLS_VERSION=69.1.0
ENV PYTHON_WHEEL_VERSION=0.42.0

###
# Create unprivileged user
###
RUN addgroup --system --gid ${CISA_GID} ${CISA_GROUP} \
    && adduser --system --uid ${CISA_UID} --ingroup ${CISA_GROUP} ${CISA_USER}

###
# Make sure the specified versions of pip, setuptools, and wheel are installed
#
# Note that we use pip3 --no-cache-dir to avoid writing to a local
# cache.  This results in a smaller final image, at the cost of
# slightly longer install times.
###
RUN pip3 install --no-cache-dir --upgrade \
    pip==${PYTHON_PIP_VERSION} \
    setuptools==${PYTHON_SETUPTOOLS_VERSION} \
    wheel==${PYTHON_WHEEL_VERSION}

###
# Install Python dependencies
#
# Note that we use pip3 --no-cache-dir to avoid writing to a local
# cache.  This results in a smaller final image, at the cost of
# slightly longer install times.
###
RUN pip3 install --no-cache-dir https://github.com/cisagov/skeleton-python-library/archive/v${VERSION}.tar.gz

###
# Prepare to run
###
ENV ECHO_MESSAGE="Hello World from Dockerfile"
WORKDIR ${CISA_HOME}
USER ${CISA_USER}:${CISA_GROUP}
EXPOSE 8080/TCP
VOLUME ["/var/log"]
ENTRYPOINT ["example"]
CMD ["--log-level", "DEBUG"]
