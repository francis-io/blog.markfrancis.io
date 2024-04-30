ARG ALPINE_VERSION
FROM alpine:${ALPINE_VERSION}

# Needs to come after FROM. https://stackoverflow.com/a/60450789
ARG HUGO_VERSION

ENV HUGO_VERSION=${HUGO_VERSION} \
    HUGO_SITE=/srv/hugo

RUN apk --no-cache add hugo=${HUGO_VERSION}

WORKDIR ${HUGO_SITE}

VOLUME ${HUGO_SITE}

#EXPOSE 80

CMD hugo server \
    --bind 0.0.0.0 \
    --port 8080 \
    --disableFastRender \  
    --cleanDestinationDir \
    --navigateToChanged \
    --gc \
    --minify \
    --navigateToChanged \
    --noBuildLock \
    --templateMetrics
