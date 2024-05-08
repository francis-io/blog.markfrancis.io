ARG ALPINE_VERSION
FROM alpine:${ALPINE_VERSION}

# Needs to come after FROM - https://stackoverflow.com/a/60450789
ARG HUGO_VERSION

ENV HUGO_VERSION=${HUGO_VERSION} \
    HUGO_SITE=/srv/hugo

RUN apk --no-cache add hugo=${HUGO_VERSION}-r0

WORKDIR ${HUGO_SITE}
VOLUME ${HUGO_SITE}

CMD hugo server \
    --bind 0.0.0.0 \
    --port 80 \
    --disableFastRender \  
    --cleanDestinationDir \
    --gc \
    --minify \
    --navigateToChanged \
    --noBuildLock
