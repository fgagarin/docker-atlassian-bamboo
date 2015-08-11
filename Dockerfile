FROM java:8

# Configuration variables.
ENV BAMBOO_HOME     /var/atlassian/bamboo
ENV BAMBOO_INSTALL  /opt/atlassian/bamboo
ENV BAMBOO_VERSION  5.9.3 

# Install Atlassian BAMBOO and helper tools and setup initial home
# directory structure.
RUN set -x \
    && apt-get update --quiet \
    && apt-get install --quiet --yes --no-install-recommends libtcnative-1 xmlstarlet \
    && apt-get clean \
    && mkdir -p                "${BAMBOO_HOME}" \
    && chmod -R 700            "${BAMBOO_HOME}" \
    && chown -R daemon:daemon  "${BAMBOO_HOME}" \
    && mkdir -p                "${BAMBOO_INSTALL}/conf/Catalina" \
    && curl -Ls                "http://www.atlassian.com/software/bamboo/downloads/binary/atlassian-bamboo-${BAMBOO_VERSION}.tar.gz" | tar -xz --directory "${BAMBOO_INSTALL}" --strip-components=1 --no-same-owner \
    && chmod -R 700            "${BAMBOO_INSTALL}/conf" \
    && chmod -R 700            "${BAMBOO_INSTALL}/logs" \
    && chmod -R 700            "${BAMBOO_INSTALL}/temp" \
    && chmod -R 700            "${BAMBOO_INSTALL}/work" \
    && chown -R daemon:daemon  "${BAMBOO_INSTALL}/conf" \
    && chown -R daemon:daemon  "${BAMBOO_INSTALL}/logs" \
    && chown -R daemon:daemon  "${BAMBOO_INSTALL}/temp" \
    && chown -R daemon:daemon  "${BAMBOO_INSTALL}/work" \
    && echo -e                 "\nbamboo.home=$BAMBOO_HOME" >> "${BAMBOO_INSTALL}/atlassian-bamboo/WEB-INF/classes/bamboo-init.properties"

# Use the default unprivileged account. This could be considered bad practice
# on systems where multiple processes end up being executed by 'daemon' but
# here we only ever run one process anyway.
USER daemon:daemon

# Expose default HTTP connector port.
EXPOSE 8085

# Set volume mount points for installation and home directory. Changes to the
# home directory needs to be persisted as well as parts of the installation
# directory due to eg. logs.
VOLUME ["/var/atlassian/bamboo"]

# Set the default working directory as the installation directory.
WORKDIR ${BAMBOO_HOME}

# Run Atlassian BAMBOO as a foreground process by default.
CMD ["/opt/atlassian/bamboo/bin/start-bamboo.sh", "-fg"]
