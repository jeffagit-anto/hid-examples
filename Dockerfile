# image build example: docker -D build  --tag docker-yst:$GHC_VERSION .
# image run example:   docker run --rm docker-yst:$GHC_VERSION
# TODO add some ghcid use case

ARG  BASE_IMAGE_TAG=8.8.4
ARG  RESOLVER=lts-16.31
ARG  REPO=hid-examples

FROM haskell:$BASE_IMAGE_TAG

# recall ARG GHC_VERSION without a value permits to use it inside the build stages
ARG RESOLVER
ENV RESOLVER=$RESOLVER

ARG REPO
ENV REPO=$REPO

WORKDIR /opt/$REPO

RUN ulimit -n 8192

# RUN stack config set system-ghc --global true

# RUN stack update

# Add just the files capturing dependencies
COPY ./$REPO.cabal  $WORKDIR
COPY ./stack.yaml   $WORKDIR
COPY ./package.yaml $WORKDIR

# Docker will cache this command as a layer, freeing us up to
# modify source code without re-installing dependencies
# (unless the .cabal file changes!)
RUN stack --resolver $RESOLVER --no-terminal test --only-dependencies --fast

# Add and Install Application Code
COPY . $WORKDIR
RUN stack --resolver $RESOLVER --no-terminal --local-bin-path $WORKDIR/bin \
           test --haddock --no-haddock-deps
