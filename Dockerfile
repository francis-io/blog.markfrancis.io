ARG ALPINE_VERSION=${ALPINE_VERSION}
FROM alpine:${ALPINE_VERSION}

ARG HUGO_VERSION=${HUGO_VERSION}

# ENV HUGO_VERSION=${HUGO_VERSION} \
#     HUGO_SITE=/srv/hugo

ENV HUGO_SITE=/srv/hugo

RUN apk --no-cache add \
        curl \
        git \
    && curl -SL https://github.com/gohugoio/hugo/releases/download/v${HUGO_VERSION}/hugo_${HUGO_VERSION}_Linux-64bit.tar.gz \
        -o /tmp/hugo.tar.gz \
    && tar -xzf /tmp/hugo.tar.gz -C /tmp \
    && mv /tmp/hugo /usr/local/bin/ \
    && apk del curl \
    && mkdir -p ${HUGO_SITE} \
    && rm -rf /tmp/*

WORKDIR ${HUGO_SITE}

VOLUME ${HUGO_SITE}

EXPOSE 1313

CMD hugo server \
    --bind 0.0.0.0 \
    --navigateToChanged \
    --templateMetrics \
    --buildDrafts
