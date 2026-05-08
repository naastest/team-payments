FROM nginxinc/nginx-unprivileged:1.27.4

# Build-time metadata baked into the image layer
ARG GIT_COMMIT=unknown
ARG GIT_BRANCH=unknown
ARG BUILD_DATE=unknown
ENV GIT_COMMIT=$GIT_COMMIT \
    GIT_BRANCH=$GIT_BRANCH \
    BUILD_DATE=$BUILD_DATE

# App source + config (nginx-unprivileged already owns its html dir as UID 101)
COPY --chown=nginx:nginx src/            /usr/share/nginx/html/
COPY                     docker/nginx.conf /etc/nginx/conf.d/default.conf
COPY --chown=nginx:nginx docker/entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

EXPOSE 8080
ENTRYPOINT ["/entrypoint.sh"]
CMD ["nginx", "-g", "daemon off;"]
